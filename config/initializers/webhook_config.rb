class Webhook
  cattr_accessor :url

  CATEGORIES_RELATION = {
    'Solicitação/colocação de contêineres' => ['S', 100],
    'Manutenção, reposição ou lavagem de contêineres' => ['S', 101],
    'Retirada de contêineres/mudança de local' => ['S', 102],
    'Coleta de conteiner não executada / limpeza do local' => ['O', 103],
    'Implantação de coleta porta a porta' => ['S', 104],
    'Coleta porta a porta não executada / limpeza do local' => ['O', 105],
    'Implantação de PEV e contêineres' =>  ['S', 106],
    'Manutenção, reposição ou lavagem de contêineres do PEV' => ['S', 107],
    'Retirada de contêineres/mudança de local-PEV' => ['S', 108],
    'Coleta de PEV e conteiner não executada / limpeza do local' => ['O', 109],
    'Implantação de coleta seletiva porta a porta' => ['S', 110],
    'Coleta seletiva porta a porta nãoexecutada/limpezsa do local' => ['O', 111],
    'Capina, corte de mato/grama em córregos, vias e área pública' => ['S', 112],
    'Capina e corte de mato em guias e sarjetas' => ['S', 113],
    'Limpeza de Feiras livres' => ['O', 114],
    'Lavagem de vias e logradouros públicos' => ['S', 115],
    'Limpeza de bocas de lobo' => ['S', 116],
    'Remoção de lixo/entulho em córregos' => ['S', 117],
    'Implantação ou colocação de papeleiras' => ['S', 118],
    'Manutenção, reposição ou lavagem de papeleiras' => ['S', 119],
    'Retirada de papeleiras' =>  ['S', 120],
    'Retirada de entulhos em calçadas e vias públicas' => ['S', 121],
    'Retirada de entulhos em área pública' => ['S', 122],
    'Solicitação de implantação de varrição' => ['S', 123],
    'Varrição em praças' => ['S', 124],
    'Varrição não executada/serviço mal executado' => ['O', 125],
    'Atraso no recolhimento do bota-fora' => ['O', 126],
    'Retirada de árvores caídas' => ['S', 127],
    'Remoção de árvores causando danos ao passeio/patrimônio' => ['S', 128],
    'Remoção de árvores com risco de queda ou doentes' => ['S', 129],
    'Poda de galhos em áreas públicas' => ['S', 130],
    'Limpeza e capinação' => ['S', 131],
    'Colocação de placas "Proibido jogar lixo e entulho"' => ['S', 132],
    'Organização e limpeza do local' => ['S', 133]
  }

  def self.enabled?
    !url.nil?
  end

  def self.external_category_id(category)
    CATEGORIES_RELATION[category.title][1]
  end

  def self.report?(category)
    CATEGORIES_RELATION[category.title][0] == 'O'
  end

  def self.solicitation?(category)
    CATEGORIES_RELATION[category.title][0] == 'S'
  end

  def self.zup_category(external_category_id)
    title = CATEGORIES_RELATION.invert.select do |k, _v|
      k[1] == external_category_id.to_i
    end.values.first

    if title.present?
      Reports::Category.find_by(title: title)
    end
  end
end

Webhook.url = ENV['WEBHOOK_URL']
