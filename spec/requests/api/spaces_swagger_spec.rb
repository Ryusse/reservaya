require 'swagger_helper'

RSpec.describe 'Spaces API', type: :request do
  path '/spaces/{id}' do
    get 'Obtener disponibilidad de un espacio' do
      tags 'Espacios'
      produces 'application/json'
      security [ bearer_auth: [], cookie_auth: [] ]

      parameter name: :id, in: :path, type: :integer, description: 'ID del espacio'
      parameter name: :date, in: :query, type: :string, required: false, description: 'Fecha de consulta (YYYY-MM-DD). Por defecto hoy.'

      response '200', 'Espacio encontrado y bloques de disponibilidad calculados' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            capacity: { type: :integer },
            location: { type: :string },
            start_time: { type: :string },
            end_time: { type: :string },
            status: { type: :string },
            space_type: { type: :string },
            date: { type: :string },
            available: { type: :boolean },
            availability: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  start_time: { type: :string },
                  end_time: { type: :string },
                  status: { type: :string, enum: [ 'free', 'partial', 'full' ] },
                  seats_available: { type: :integer }
                }
              }
            },
            reservations: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  user_id: { type: :integer },
                  date: { type: :string },
                  start_time: { type: :string },
                  end_time: { type: :string },
                  status: { type: :string },
                  seats_reserved: { type: :integer }
                }
              }
            }
          }

        let(:id) { create(:space, status: :active).id }
        let(:date) { Date.current.to_s }

        before do
          user = User.create!(name: "Test", email: "test@test.com", password: "Password123", role: :user)
          post "/session", params: { email: user.email, password: "Password123" }, as: :json
        end

        run_test!
      end

      response '404', 'Espacio no encontrado' do
        let(:id) { 99999 }

        before do
          user = User.create!(name: "Test", email: "test@test.com", password: "Password123", role: :user)
          post "/session", params: { email: user.email, password: "Password123" }, as: :json
        end

        run_test!
      end
    end
  end
end
