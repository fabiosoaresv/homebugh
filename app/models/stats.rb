class Stats
  attr_reader :relation, :currency

  def initialize(currency, relation = AggregatedTransaction)
    if currency.is_a? Currency
      @relation = relation.currency(currency.id)
    else
      @relation = relation.none
    end
  end

  def all
    Enumerator.new do |yielder|
      months.each do |month|
        yielder << {
          month => {
            income: @relation.income.month(month).load,
            spending: @relation.spending.month(month).load
          }
        }
      end
    end
  end

  private

  def months
    relation.order(period_started_at: :desc).pluck(:period_started_at).uniq
  end
end
