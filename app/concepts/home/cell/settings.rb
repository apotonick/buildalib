module Home::Cell
  class Settings < Trailblazer::Cell
    def email
      model.email
    end
  end
end
