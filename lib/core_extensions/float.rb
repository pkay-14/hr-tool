module CoreExtensions
  module Float
    def round_to_half
      (self * 2.0).round / 2.0
    end
  end
end
