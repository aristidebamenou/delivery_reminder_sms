class DeliveryReminderSms
  # Vérité 2 : ces consignes doivent repartir à CHAQUE appel.
  # Vérité 3 : elles sont donc facturées en entrée à chaque appel.
  SYSTEM_PROMPT = <<~TXT
    Tu rédiges des SMS de relance de livraison.
    Vouvoiement, 160 caractères maximum, aucun lien,
    signature "L'équipe Livraison". Réponds uniquement par le texte du SMS.
  TXT

  def call(customer_name:, tracking_number:, eta:)
    message = ANTHROPIC_CLIENT.messages.create(
      model: Anthropic::Model::CLAUDE_HAIKU_5_5, # équivaut à "claude-haiku-5-5"
      max_tokens: 1024,                          # plafond de génération, rien n'est réservé
      system: SYSTEM_PROMPT,
      messages: [
        { role: "user",
          content: "Client : #{customer_name}. Colis #{tracking_number}. Livraison prévue : #{eta}." }
      ]
    )

    # stop_reason est un Symbol : comparer à :max_tokens, pas à "max_tokens"
    raise "Réponse tronquée" if message.stop_reason == :max_tokens

    # content est un tableau de blocs : on ne garde que les blocs texte,
    # quel que soit leur rang (un bloc :thinking peut précéder)
    sms = message.content.select { |block| block.type == :text }.map(&:text).join

    # Vérité 3 : le compteur de facturation
    Rails.logger.info(
      "[claude] in=#{message.usage.input_tokens} out=#{message.usage.output_tokens}"
    )

    sms
  end
end
