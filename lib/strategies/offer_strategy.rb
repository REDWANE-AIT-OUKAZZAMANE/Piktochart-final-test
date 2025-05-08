class OfferStrategy
  def apply_offer(items)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
  
  def applicable?(items)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
end 