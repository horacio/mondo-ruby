FactoryGirl.define do
  factory :feed_item, class: 'Mondo::FeedItem', parent: :resource do
    parameters do
      {
        title: "Library of Babel donation",
        title_color: "#333",
        image_url: "https://upload.wikimedia.org/../../Minotaur.png",
        background_color: "#FCF1EE",
        body: "The things you own, end up owning you.",
        body_color: "#FCF1EE",
        url: "https://libraryofbabel.info/"
      }
    end

    initialize_with do
      new(parameters, client)
    end
  end
end
