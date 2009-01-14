module I18nHelper
  # To use do:
  #   require 'i18n_helper'
  #   I18n.send :include, I18nHelper

  def self.included(base) 
    base.module_eval do
      class << self
        # Translate the string in the current locale.  If it doesn't exist
        # then try on the broader locale (ie. if we tried from en-US, then 
        # try 'en').  If still no go then use the default text.
        def translate_with_inheritance(text, options = {})
          translation = translate_without_inheritance(text, options_without_default(options).merge(:raise => true))
        rescue I18n::MissingTranslationData
          locale = options[:locale] || I18n.locale
          translation = translate_without_inheritance(text, options.merge(:locale => broader_locale(locale))) if broader_locale(locale)
        end

        def broader_locale(locale)
          broader ||= locale.split('-')[0]
        end
        
        def options_without_default(options)
          options.reject{|k, v| k == :default}
        end
        
        alias_method_chain :translate, :inheritance
        alias_method :t, :translate_with_inheritance
      end
    end 
  end
end