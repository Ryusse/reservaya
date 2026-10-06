require 'swagger_helper'

RSpec.describe 'Auth API', type: :request do
  path '/register' do
    post 'Registro de usuario cliente' do
      tags 'Autenticación'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              name: { type: :string },
              email: { type: :string },
              password: { type: :string }
            },
            required: [ 'name', 'email', 'password' ]
          }
        }
      }

      response '201', 'Usuario creado. Retorna cookie de sesión.' do
        let(:user) { { user: { name: 'Juan', email: 'juan@test.com', password: 'Password123' } } }
        run_test!
      end

      response '422', 'Parámetros inválidos' do
        let(:user) { { user: { name: '' } } }
        run_test!
      end
    end
  end

  path '/session' do
    post 'Iniciar sesión' do
      tags 'Autenticación'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string }
        },
        required: [ 'email', 'password' ]
      }

      response '200', 'Sesión iniciada. Retorna cookie de sesión.' do
        before do
          User.create!(name: "Test", email: "test@test.com", password: "Password123", role: :user)
        end
        let(:credentials) { { email: 'test@test.com', password: 'Password123' } }
        run_test!
      end

      response '401', 'Credenciales inválidas' do
        let(:credentials) { { email: 'test@test.com', password: 'wrong' } }
        run_test!
      end
    end

    get 'Obtener usuario actual' do
      tags 'Autenticación'
      produces 'application/json'
      security [ bearer_auth: [], cookie_auth: [] ]

      response '200', 'Usuario actual' do
        before do
          user = User.create!(name: "Test", email: "test@test.com", password: "Password123", role: :user)
          post "/session", params: { email: user.email, password: "Password123" }, as: :json
        end
        run_test!
      end

      response '401', 'No autorizado' do
        run_test!
      end
    end

    delete 'Cerrar sesión' do
      tags 'Autenticación'
      produces 'application/json'
      security [ bearer_auth: [], cookie_auth: [] ]

      response '200', 'Sesión cerrada' do
        before do
          user = User.create!(name: "Test", email: "test@test.com", password: "Password123", role: :user)
          post "/session", params: { email: user.email, password: "Password123" }, as: :json
        end
        run_test!
      end
    end
  end
end
