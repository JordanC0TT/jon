# frozen_string_literal: true

require "images/helpers/regex_helpers"

module Catalogage
  module Etape
    # Permet de vérifier les fichiers en conflit dans la destination
    class Verificateur
      def initialize(index_fichiers_destination = [], index_fichiers_analyses = [], fichiers_conflit = {})
        @index_fichiers_destination = index_fichiers_destination
        @index_fichiers_analyses = index_fichiers_analyses
        @fichiers_conflit = fichiers_conflit
        @log = Logging.logger["Verificateur"]
      end

      def index(fichiers_analyses, path_destination)
        index_destination(path_destination)
        index_fichiers_analyses(fichiers_analyses, path_destination)
        @index_fichiers_analyses.each do |fichier_analyse|
          @fichiers_conflit.store(fichier_analyse, @index_fichiers_destination.include?(fichier_analyse))
        end
        @fichiers_conflit
      end

      def conflit
        @fichiers_conflit.select { |_k, v| v == true }
      end

      private

      def index_fichiers_analyses(fichiers_analyses, path_destination)
        fichiers_analyses.each_value do |fichiers|
          fichiers.each do |fichier|
            @index_fichiers_analyses.push fichier.path_nouveau_nom("#{path_destination}/#{fichier.path_destination}")
          end
        end
      end

      def index_destination(destination)
        Dir.each_child(destination) do |nom_fichier|
          fichier = "#{destination}/#{nom_fichier}"
          if File.file?(fichier)
            @index_fichiers_destination.push fichier if File.extname(fichier) =~ RegexHelpers::EXTENSIONS_EXCLUS
          else
            index_destination(fichier)
            next
          end
        end
      end
    end
  end
end
