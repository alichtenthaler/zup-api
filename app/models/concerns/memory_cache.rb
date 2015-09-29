class MemoryCacheImpl
  def initialize(model, tables_to_ignore)
    @model = model
    @tables_with_triggers = []
    @redis = Redis.new url: ENV['REDIS_URL'] || 'redis://127.0.0.1:6379/zup'
    @lock_manager = Redlock::Client.new([@redis])
    @lock_key = 'memory-cache-lock:' + @model.table_name.to_s
    @queue_key = 'memory-cache-queue:' + @model.table_name.to_s
    @local_queue_length = @redis.llen(@queue_key)
    @thread_id = Thread.current.object_id.to_s
    @tables_to_ignore = tables_to_ignore.map { |t| t.to_s }
  end

  def create_trigger(table, field = 'id')
    <<-SQL
    CREATE OR REPLACE FUNCTION object_notify_#{table}_#{@thread_id}() RETURNS trigger AS $$
    DECLARE
    BEGIN
      PERFORM pg_notify('object_updated_#{@thread_id}', CAST(NEW.#{field} AS text) || ':' || txid_current());
      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
    SQL
  end

  def create_after_update_triggers
    tables = @model.reflect_on_all_associations.map { |r| [r.table_name, r.foreign_key] }
    tables = tables.select { |t| !@tables_to_ignore.include?(t[0]) }
    tables << [@model.table_name, 'id']

    tables.each do |table|
      @model.connection.execute("DROP TRIGGER IF EXISTS object_post_insert_notify_#{@thread_id} ON #{table[0]};")
      @model.connection.execute(create_trigger(table[0], table[1]))
      @model.connection.execute("CREATE TRIGGER object_post_insert_notify_#{@thread_id} AFTER UPDATE ON #{table[0]} FOR EACH ROW EXECUTE PROCEDURE object_notify_#{table[0]}_#{@thread_id}();")
    end

    @tables_with_triggers += tables.map { |t| t[0] }
  end

  def clear_triggers
    @tables_with_triggers.each { |t| clear_trigger_on_table(t) }
  end

  def clear_trigger_on_table(table_name)
    return if ENV['DISABLE_MEMORY_CACHE'] == 'true'
    table_name = table_name.to_s
    @model.connection.execute("DROP TRIGGER IF EXISTS object_post_insert_notify_#{@thread_id} ON #{table_name};")
    @model.connection.execute("DROP FUNCTION IF EXISTS object_notify_#{table_name}_#{@thread_id}();")
  end

  def update_cache(cache)
    if @redis.llen(@queue_key) > @local_queue_length
      updates = @redis.lrange(@queue_key, @local_queue_length - 1, -1)
      updates.each do |update_id|
        object_id, _ = update_id.split(':')
        object_id = object_id.to_i
        if cache[object_id]
          begin
            cache[object_id].reload
          rescue ActiveRecord::RecordNotFound
            cache[object_id] = nil
          end
        end
      end
    end
  end

  # This is executed on a separate thread
  def queue_object_update(id)
    @lock_manager.lock(@lock_key, 100) do |locked|
      if locked
        if @redis.lrange(@queue_key, -1, -1)[0] != id
          @redis.rpush(@queue_key, id)
        end
      else
        Raven.capture("Unable to retrieve lock for #{@queue_key} in order to insert update #{id}")
      end
    end
  end

  # This is executed on a separate thread
  def listen_for_object_changes
    must_shutdown = false

    trap('EXIT') do
      must_shutdown = true
    end

    conn = @model.connection

    begin
      conn.execute "LISTEN object_updated_#{@thread_id}"

      loop do
        conn.raw_connection.wait_for_notify do |_, __, id|
          queue_object_update(id)
        end

        break if must_shutdown
      end
    ensure
      conn.execute "UNLISTEN object_updated_#{@thread_id}"
      clear_triggers
    end
  end
end

module MemoryCache
  extend ActiveSupport::Concern

  included do
    class_eval do
      @memory_cache = {}
      @cache_version = 0
    end

    class << self
      attr_reader :cache_version
    end
  end

  module ClassMethods
    def cached_find(object_ids)
      if ENV['DISABLE_MEMORY_CACHE'] == 'true'
        @cache_version += 1
        return find(object_ids)
      end

      if @memory_cache_instance.update_cache(@memory_cache)
        @cache_version += 1
      end

      objects = []
      missing_object_ids = []
      object_ids.each do |group_id|
        if @memory_cache[group_id]
          objects << @memory_cache[group_id]
        else
          missing_object_ids << group_id
        end
      end

      unless missing_object_ids.empty?
        find(missing_object_ids).each do |group|
          @memory_cache[group.id] = group
          objects << @memory_cache[group.id]
        end
      end

      objects
    end

    # Make sure you call this after the associations have been declared
    def enable_memory_cache(options)
      if instance_variable_get(:@memory_cache_instance)
        warn 'MemoryCache has already been enabled for class ' + self.class.to_s
        return
      end

      unless ENV['DISABLE_MEMORY_CACHE'] == 'true'
        options[:ignore_assoc_table] = [options[:ignore_assoc_table]] unless options[:ignore_assoc_table].is_a?(Array)
        memory_cache_instance = MemoryCacheImpl.new(self, options[:ignore_assoc_table])
        instance_variable_set(:@memory_cache_instance, memory_cache_instance)

        memory_cache_instance.create_after_update_triggers

        Thread.new do
          memory_cache_instance.listen_for_object_changes
        end
      end
    end
  end
end
