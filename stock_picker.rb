def stock_picker(prices)
  buy_day = 0
  sell_day = 0
  max_profit = 0

  prices.each_with_index do |buyprice, index|
    prices[index+1..].each_with_index do |sellprice, index2|
      if sellprice - buyprice > max_profit
        buy_day = index
        sell_day = index2 + index + 1
        max_profit = sellprice - buyprice
      end
    end
  end
  return [buy_day, sell_day, max_profit]
end
puts stock_picker([17,3,6,9,15,8,6,1,10])
