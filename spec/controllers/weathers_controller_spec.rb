require 'rails_helper'

RSpec.describe WeathersController, type: :controller do
  describe 'GET #index' do
    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    context 'with a valid zip code' do
      it 'fetches weather data and renders the show template' do
        get :show, params: { zip_code: '12345' }
        expect(response).to render_template(:show)
      end
    end

    context 'with an invalid zip code' do
      it 'sets flash error and redirects to index' do
        get :show, params: { zip_code: 'invalid' }
        expect(flash[:error]).to eq("Invalid zip code. Please enter a 5-digit or longer numeric zip code.")
        expect(response).to redirect_to(weathers_path)
      end
    end
  end
end
