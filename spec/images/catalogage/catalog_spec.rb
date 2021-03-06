# frozen_string_literal: true

require "images/catalogage/catalog"
require "images/catalogage/etape/analyse"
require "images/catalogage/etape/application"
require "images/catalogage/etape/nom_attribuer"
require "images/catalogage/etape/verificateur"

require "images/exif/mini_exiftool_manipulateur"

require "images/extraction/extracteur_par_date"

RSpec.describe Catalogage::Catalog do
  describe "doit cataloguer" do
    before do
      @dossier_tmp = FileUtils.makedirs "#{FileHelpers::TMP}rspec_catalog"
    end

    where(:case_name, :fichiers, :attendu) do
      [
        ["le dossier camera",
         { "camera" => ["PHOTO-2021-09-19-10-08-06.png"] },
         [
           ""
         ]]
      ]
    end
    with_them do
      it do
        FileHelpers.build_fichiers(fichiers, @dossier_tmp[0])
        dossier_destination = FileUtils.mkdir_p("#{FileHelpers::TMP}rspec_catalog/destination")
        exif_manipulateur_mock = mock
        extracteur_mock = mock

        Catalogage::Catalog.new(
          Catalogage::Etape::Analyse.new(extracteur_mock, exif_manipulateur_mock),
          Catalogage::Etape::NomAttribuer.new,
          Catalogage::Etape::Application.new(exif_manipulateur_mock),
          Catalogage::Etape::Verificateur.new
        ).process(@dossier_tmp[0], true, dossier_destination[0])
      end

      after do
        FileUtils.rm_rf(@dossier_tmp[0])
      end
    end
  end
end
