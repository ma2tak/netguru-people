class UserSkillRatesController < ApplicationController
  expose(:user_skill_rate) { UserSkillRate.find(params[:id]) }
  expose(:grouped_skills_by_category) do
    GroupUserSkillRatesBySkillCategoriesQuery.new(current_user).results
  end

  def index
    respond_to do |format|
      format.html
      format.json { render json: grouped_skills_by_category }
    end
  end

  def update
    respond_to do |format|
      if user_skill_rate.update(user_skill_rate_params)
        format.html { redirect_to user_skill_rate, notice: 'Skill was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: user_skill_rate.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def user_skill_rate_params
    params.require(:user_skill_rate).permit(:rate, :note, :favorite)
  end
end
