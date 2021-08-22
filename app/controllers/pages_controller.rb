# frozen_string_literal: true

class PagesController < ApplicationController
  def show
    render_erb || not_found
  end

  private

  def render_erb
    path = Rails.root.join("app", "views", "pages", "#{params[:id]}.html.erb")
    render(params[:id]) if path.exist?
  end
end
