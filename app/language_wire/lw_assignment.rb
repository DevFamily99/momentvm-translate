# Contains pages, there is one assignment per target lang
class LwAssignment
  attr_accessor :target_language
  attr_accessor :source_language
  attr_accessor :deadline
  attr_accessor :status
  attr_accessor :workArea
  attr_accessor :distant_key
  attr_accessor :documents
  def initialize
    self.documents = []
  end
end
