module Home::Cell
  class Dashboard < Trailblazer::Cell
    def email
      model.email
    end
  end
end
