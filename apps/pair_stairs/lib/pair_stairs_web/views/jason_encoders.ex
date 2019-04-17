require Protocol
Protocol.derive(Jason.Encoder, Parear.Participant, only: [:id, :name])
Protocol.derive(Jason.Encoder, Parear.Stairs, only: [:id, :participants, :statuses])
