
Rails.application.routes.draw do

  # 打刻画面
  root "punches#index"

  # 出勤・退勤・休憩
  post "/punch",
       to: "punches#create",
       as: :punch

  # 勤務状況の自動更新
  get "/punch/status",
      to: "punches#status",
      as: :punch_status

  # 勤務履歴・CSV出力
  get "/timecards",
      to: "timecards#index",
      as: :timecards

  # 勤務履歴の編集
  patch "/timecards/:id",
        to: "timecards#update",
        as: :timecard

  # 勤務履歴の削除
  delete "/timecards/:id",
         to: "timecards#destroy"

  # スタッフ管理・管理者ログインは別担当
  # 既に実装されているルートがあれば残す

end
