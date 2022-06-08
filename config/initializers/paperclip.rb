module Paperclip
  class MediaTypeSpoofDetector
	def spoofed?
	  false
	end
  end
end

Paperclip::DataUriAdapter.register
