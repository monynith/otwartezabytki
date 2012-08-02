# -*- encoding : utf-8 -*-
module RelicsHelper
  def thank_you_note
    [
      "Dzięki Tobie Cyfrowy Czyn Społeczny działa :)",
      "Zabytki są Ci wdzięczne :)",
      "Cieszymy się, że otwierasz z nami zabytki :)",
      "Zabytki lubią być otwarte. Dziękujemy! :)",
      "Jesteś naszym zabytkowym aniołem :)",
      "Od zabytków głowa nie boli :) Dziękujemy!",
      "Każdy sprawdzony zabytek to krok do sukcesu akcji. Dziękujemy :)",
      "Miło, że poświęcasz swój czas na otwieranie zabytków :)",
      "Zabytki leżą nam na sercu :) Doceniamy, że bierzesz udział w akcji.",
      "Kolejny sprawdzony zabytek :) Ale fajnie!",
      "Dziękujemy! Im nas więcej, tym lepiej :)"
    ].sample
  end

  def categoires_facets
    relics.terms('categories', true).map do |t|
      ["#{Tag.all.key(t['term'])} (#{t['count']})", t['term']]
    end
  end

  def state_facets
    labels = Hash[Relic::States.zip(['sprawdzone', 'niesprawdzone', 'uzupełnione'])]
    relics.terms('state', true).map do |t|
      ["#{labels[t['term']]} (#{t['count']})", t['term']]
    end
  end

  def existance_facets
    labels = Hash[Relic::Existences.zip(['istniejące', 'archiwalne', 'społecznosciowe'])]
    relics.terms('existance', true).map do |t|
      ["#{labels[t['term']]} (#{t['count']})", t['term']]
    end
  end
end
