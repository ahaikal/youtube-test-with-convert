
class Video < ActiveRecord::Base
include AASM
  has_attached_file :source
  validates_attachment_presence :source
  validates_attachment_content_type :source, :content_type => 'video/quicktime'
aasm :column => 'state' do
  state :pending, :initial => true
  state :pending
  state :converting
  state :converted, :enter => :set_new_filename
  state :error

  event :convert do
    transitions :from => :pending, :to => :converting
  end

  event :converted do
    transitions :from => :converting, :to => :converted
  end

  event :failed do
    transitions :from => :converting, :to => :error
  end
end
#---------------------------------------------------------
def convert
  self.convert!
  success = system(convert_command)
  if success && $?.exitstatus == 0
    self.converted!
  else
    self.failure!
  end
end

protected

# This method creates the ffmpeg command that we'll be using
def convert_command
  flv = File.join(File.dirname(source.path), "#{id}.flv")
  File.open(flv, 'w')

  command = <<-end_command
    ffmpeg -i #{ source.path } -ar 22050 -ab 32 -acodec mp3
  -s 480x360 -vcodec flv -r 25 -qscale 8 -f flv -y #{ flv }
  end_command
  command.gsub!(/\s+/, " ")
end

# This update the stored filename with the new flash video file
def set_new_filename
  update_attribute(:source_file_name, "#{id}.flv")
end

end
