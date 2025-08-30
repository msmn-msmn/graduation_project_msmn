class AddConfirmableToDeviseUsers < ActiveRecord::Migration[7.2]
  # Userに追加するカラム
  def up
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :unconfirmed_email, :string
    add_index :users, :confirmation_token, unique: true
    
    # 既存ユーザーを確認済み状態にする
    User.update_all confirmed_at: DateTime.now
  end

  # ロールバックで外すカラム
  def down
    remove_columns :users, :confirmation_token, :confirmed_at, :confirmation_sent_at, :unconfirmed_email
  end
end
