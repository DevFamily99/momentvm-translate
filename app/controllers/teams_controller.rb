class  TeamsController < ApplicationController

	def create
		team = Team.find_or_create_by(team_params)
		if team.present?
			return render json: {message: "Team created"}
		else
			render json: {errors: team.errors}, status: 400
		end					
	end

	def team_params
		params.require(:team).permit(:id, :name)
	end
end
