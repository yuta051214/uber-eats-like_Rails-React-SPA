class Api::V1::LineFoodsController < ApplicationController
  # 「@ordered_food」に注文対象のFoodインスタンスを代入
  before_action :set_food, only: [:create, :replace]

  def index
    # activeがtrueであるLineFood(仮注文)の一覧を取得
    line_foods = LineFood.active
    if line_foods.exists?
      render json: {
        line_food_ids: line_foods.map{ |line_food| line_food.id },
        restaurant: line_foods[0].restaurant,
        # 注文総数
        count: line_foods.sum { |line_food| line_food[:count] },
        # 合計金額
        amount: line_foods.sum { |line_food| line_food.total_amount },
      }, status: :ok
    else
      render json: {}, status: :no_content
    end
  end

  def create
    # 早期リターン：他店舗での仮注文が既にある場合
    # 他店舗でアクティブなLineFoodを取得して、それが存在するかどうかを判断する
    if LineFood.active.other_restaurant(@ordered_food.restaurant.id).exist?
      # リターンで処理を終えて、jsonとエラーコードを返す
      return render json: {
        # 他店舗の情報
        existing_restaurant: LineFood.other_restaurant(@ordered_food.restaurant.id).first.restaurant.name,
        # 新店舗の情報
        new_restaurant: Food.find(params[:food_id]).restaurant.name,
      }, status: :not_acceptable
    end

    # LineFoodインスタンスを生成
    self.set_line_food(@ordered_food)

    # LineFoodインスタンスを保存
    if @line_food.save
      render json: {
        line_food: @line_food
      }, status: :created
    else
      render json: {}, status: :internal_server_error
    end
  end

  # 既に存在している古い仮注文(active: trueの状態)を論理削除(active: falseの状態に)し、新しいレコードを作成する。
  def replace
    LineFood.active.other_restaurant(@ordered_food.restaurant.id).each do |line_food|
      line_food.update_attribute(:active, false)
    end

    set_line_food(@ordered_food)

    if @line_food.save
      render :json {
        line_foods: @line_food
      }, status: :created
    else
      render json: {}, status: :internal_server_error
    end
  end


  private
    # フィルター
    def set_food
      @ordered_food = Food.find(params[:food_id])
    end

    def set_line_food(ordered_food)
      # 既に同じFoodに関するLineFoodが存在する場合、既存のLineFoodインスタンスを更新する
      if ordered_food.line_food.present?
        @line_food = ordered_food.line_food
        @line_food.attributes = {
          count: ordered_food.line_food.count + params[:count],
          active: true
        }
      else
      # 同じFoodに関するLineFoodが存在しない場合、LineFoodインスタンスを新規作成する
        @line_food = ordered_food.build_line_food(
          count: params[:count],
          restaurant: ordered_food.restaurant,
          active: true
        )
      end
    end
end
