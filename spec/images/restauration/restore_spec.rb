# frozen_string_literal: true

require "images/restauration/etape/analyse"
require "images/restauration/etape/traitement_dossier_extirpable"
require "images/restauration/etape/traitement_dossier_non_extirpable"
require "images/restauration/etape/application"
require "images/restauration/restore"

require "images/exif/mini_exiftool_manipulateur"

require "images/extraction/extracteur_par_date"

RSpec.describe Restauration::Restore do
  describe "doit restaurer" do
    before do
      @dossier_tmp = FileUtils.makedirs "#{FileHelpers::TMP}test01"
    end

    where(:case_name, :fichiers, :attendu) do
      [
        ["le dossier",
         { "/2012/01" => ["P000053.png", "P000054.png", "P000056.png"],
           "/2012/02" => ["20120228_155747.png", "IMG_20120203175810.jpeg", "05-02-2012 21-26-00.png"] },
         ["#{FileHelpers::TMP}test01/2012/01/PNG/001.png",
          "#{FileHelpers::TMP}test01/2012/01/PNG/002.png",
          "#{FileHelpers::TMP}test01/2012/01/PNG/003.png",
          "#{FileHelpers::TMP}test01/2012/02/PNG/photo_2012_02_28-15_57_47.png",
          "#{FileHelpers::TMP}test01/2012/02/JPG/photo_2012_02_03-17_58_10.jpeg",
          "#{FileHelpers::TMP}test01/2012/02/PNG/photo_2012_02_05-21_26_00.png"]]
      ]
    end
    with_them do
      it "afin de reattribuer les metadatas, le nommage et l'emplacement des fichiers" do
        FileHelpers.build_fichiers(fichiers, @dossier_tmp[0])
        exif_manipulateur_mock = mock
        exif_manipulateur_mock.stubs(:set_datetimeoriginal).with(
          "#{FileHelpers::TMP}test01/2012/02/20120228_155747.png", DateTime.new(2012, 2, 28, 15, 57, 47)
        )
        exif_manipulateur_mock.stubs(:set_datetimeoriginal).with(
          "#{FileHelpers::TMP}test01/2012/02/IMG_20120203175810.jpeg", DateTime.new(2012, 2, 3, 17, 58, 10)
        )
        exif_manipulateur_mock.stubs(:set_datetimeoriginal).with(
          "#{FileHelpers::TMP}test01/2012/02/05-02-2012 21-26-00.png", DateTime.new(2012, 2, 5, 21, 26, 0)
        )
        exif_manipulateur_mock.stubs(:set_datetimeoriginal).with("#{FileHelpers::TMP}test01/2012/01/P000053.png",
                                                                 DateTime.new(2012, 1, 1, 0, 0, 0))
        exif_manipulateur_mock.stubs(:set_datetimeoriginal).with("#{FileHelpers::TMP}test01/2012/01/P000054.png",
                                                                 DateTime.new(2012, 1, 1, 0, 0, 0))
        exif_manipulateur_mock.stubs(:set_datetimeoriginal).with("#{FileHelpers::TMP}test01/2012/01/P000056.png",
                                                                 DateTime.new(2012, 1, 1, 0, 0, 0))
        extracteur_mock = mock
        extracteur_mock.stubs(:extirpabilite).with("#{FileHelpers::TMP}test01/2012/02/20120228_155747.png").then.returns(true)
        extracteur_mock.stubs(:extirpabilite).with("#{FileHelpers::TMP}test01/2012/02/IMG_20120203175810.jpeg").then.returns(true)
        extracteur_mock.stubs(:extirpabilite).with("#{FileHelpers::TMP}test01/2012/02/05-02-2012 21-26-00.png").then.returns(true)
        extracteur_mock.stubs(:extirpabilite).with("#{FileHelpers::TMP}test01/2012/01/P000053.png").then.returns(false)
        extracteur_mock.stubs(:extirpabilite).with("#{FileHelpers::TMP}test01/2012/01/P000054.png").then.returns(false)
        extracteur_mock.stubs(:extirpabilite).with("#{FileHelpers::TMP}test01/2012/01/P000056.png").then.returns(false)
        extracteur_mock.stubs(:extraction_du).with("20120228_155747").then.returns(DateTime.new(2012, 2, 28, 15, 57,
                                                                                                47))
        extracteur_mock.stubs(:extraction_du).with("IMG_20120203175810").then.returns(DateTime.new(2012, 2, 3, 17, 58,
                                                                                                   10))
        extracteur_mock.stubs(:extraction_du).with("05-02-2012 21-26-00").then.returns(DateTime.new(2012, 2, 5, 21, 26,
                                                                                                    0))

        Restauration::Restore.new(
          Restauration::Etape::Analyse.new(extracteur_mock),
          Restauration::Etape::TraitementDossierExtirpable.new(extracteur_mock),
          Restauration::Etape::TraitementDossierNonExtirpable.new,
          Restauration::Etape::Application.new(exif_manipulateur_mock),
        ).process(@dossier_tmp[0], true)

        expect(FileHelpers.nombre_fichiers(@dossier_tmp[0])).to eql attendu.length
        attendu.each do |fichier|
          expect(File).to exist(fichier)
        end
      end

      after do
        FileUtils.rm_rf(@dossier_tmp[0])
      end
    end
  end
end
