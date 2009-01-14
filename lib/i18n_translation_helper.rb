module I18nTranslationHelper
  # To use do:
  #   require 'i18n_helper'
  #   I18n.send :include, I18nHelper

  def self.included(base) 
    base.module_eval do
      class << self
        def translate_with_fallback(text, options = {})
          default = options.delete(:default)
          locale_lookup_chain(options[:locale] || locale).each do |lookup_locale|
            translation_found, translation = attempt_translation(text, options.merge(:locale => lookup_locale))
            return translation if translation_found
          end
          # Ensure 'translation missing' return is exactly the default behaviour
          translate_without_fallback(text, options.merge(:default => default))
        end
        
        def attempt_translation(text, options = {})
          puts "Attempting translation of '#{text}' with locale '#{options[:locale]}'." if options[:debug]
          translation = translate_without_fallback(text, options.merge(:raise => true))
          translation_found = options[:locale]
        rescue I18n::MissingTranslationData
          translation_found = nil
          translation = "translation missing: #{options[:locale]}, #{text}"
        ensure
          return translation_found, translation
        end

        def root_locale(locale)
          locale.to_s.split('-')[0]
        end
        
        def locate(text, options = {})
          locale_lookup_chain(options[:locale] || locale).each do |lookup_locale|
            translation_found, translation = attempt_translation(text, options.merge(:locale => lookup_locale))
            return "#{lookup_locale}: '#{translation}'" if translation_found
          end
          return nil
        end
        
        def locale_lookup_chain(locale)
          @i18n_fallback_locales ||= {}
          unless @i18n_fallback_locales[locale.to_sym]
            base_locale = (root_locale(locale) || locale).to_sym
            locales = [locale.to_sym, base_locale]
            available_locales.each do |l|
              current_base_locale = root_locale(l)
              locales << l if current_base_locale && current_base_locale.to_sym == base_locale
            end if respond_to?(:available_locales)
            @i18n_fallback_locales[locale.to_sym] = locales.uniq
          end
          @i18n_fallback_locales[locale.to_sym]
        end
          
        alias_method_chain :translate, :fallback
        alias_method :t, :translate_with_fallback
      end
    end 
  end
end
