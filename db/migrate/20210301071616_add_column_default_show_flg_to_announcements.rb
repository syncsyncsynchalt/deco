class AddColumnDefaultShowFlgToAnnouncements < ActiveRecord::Migration[5.1]
  def change
    add_column(:announcements, :show_flg, :integer, :default => 1, :after => :body)
    add_column(:announcements, :begin_at, :timestamp, :after => :show_flg)
    add_column(:announcements, :end_at, :timestamp, :after => :begin_at)
    add_column(:announcements, :body_show_flg, :integer, :default => 0, :after => :end_at)
  end
end
