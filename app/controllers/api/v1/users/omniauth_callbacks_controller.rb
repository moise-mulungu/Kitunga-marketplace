module Api
  module V1
    module Users
      class OmniauthCallbacksController < Devise::OmniauthCallbacksController
        # Expect JSON-based flow where frontend handles redirection

        def passthru
          super
        end
      
       def google_oauth2
          # Build or locate user from the omniauth hash
          @user = User.from_omniauth(request.env['omniauth.auth'])

          # The frontend may pass the intended role as a query param when
          # initiating the OAuth request (e.g. ?role=seller). OmniAuth makes
          # these available under `omniauth.params` on the callback request.
          # Try a few places for the requested role: env, params, and session
          env_params = request.env['omniauth.params'] rescue nil
          session_params = session['omniauth.params'] || session[:omniauth_params]
          requested_role = if env_params && env_params['role']
                              env_params['role']
                            elsif params[:role].present?
                              params[:role]
                            elsif session_params && session_params['role']
                              session_params['role']
                            end

          # Debug logging to help track where role values come from in dev
          Rails.logger.debug "OmniAuth role sources: env=#{env_params.inspect}, params=#{params[:role].inspect}, session=#{session_params.inspect}, chosen=#{requested_role.inspect}"

          # If a role was requested and the user was just created (no role set),
          # persist it so downstream logic (redirects) can use the role.
          if requested_role.present? && @user && @user.role.blank?
            # Only allow known roles to be assigned
            allowed_roles = %w[customer seller admin]
            if allowed_roles.include?(requested_role)
              @user.update(role: requested_role)
            end
          end

          if @user.persisted?
            sign_in @user
            # devise-jwt will place the generated token in `request.env['warden-jwt_auth.token']`
            # for configured dispatch requests. Avoid referencing an undefined
            # helper (`current_token`) and read the token directly from the env.
            token = request.env['warden-jwt_auth.token']

            # Determine frontend path based on user role. For sellers we
            # send them to the setup page so they can complete their
            # seller profile after signing up with Google.
            dashboard_path = case @user.role
                            when 'seller'
                              '/seller/setup'
                            else
                              '/client/dashboard'
                            end

            # Include role in the frontend redirect so the UI can react
            # (e.g., route sellers to the setup page).
            role_query = @user.role.present? ? "&role=#{CGI.escape(@user.role)}" : ''
            frontend_url = "http://localhost:3001#{dashboard_path}?token=#{token}#{role_query}"

            respond_to do |format|
              # API request expects JSON
              format.json do
                render json: {
                  message: 'Signed in with Google',
                  user: @user,
                  access_token: token,
                  redirect_url: frontend_url
                }
              end

              # Browser request redirects directly
              format.html { redirect_to frontend_url }
            end
          else
            respond_to do |format|
              format.json { render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity }
              format.html { render plain: 'Authentication failed', status: :unauthorized }
            end
          end
        end

        def failure
          # OmniAuth populates `request.env['omniauth.error']` with the
          # exception object when a failure occurs (network, CSRF, etc.).
          omniauth_error = request.env['omniauth.error']
          error_message = if omniauth_error.respond_to?(:message)
                            omniauth_error.message
                          else
                            params[:error] || 'Omniauth failure'
                          end

          # Log full details server-side for debugging (stack trace will
          # be in the logs). Don't expose backtraces to the client.
          Rails.logger.error "OmniAuth failure: #{omniauth_error.inspect}" if omniauth_error

          respond_to do |format|
            format.json { render json: { error: 'Omniauth failure', message: error_message }, status: :unauthorized }
            format.html do
              # Redirect the browser back to the frontend with a readable
              # error query param so the UI can show a user-friendly message.
              frontend_error_url = "http://localhost:3001/login?error=#{CGI.escape(error_message)}"
              redirect_to frontend_error_url
            end
          end
        end
      end

      # Support the developer omniauth strategy used in development for testing.
      # This mirrors the google_oauth2 flow so local dev can simulate provider
      # callbacks without making network calls.
      def developer
        # Reuse the same implementation as google_oauth2 but keep method name
        @user = User.from_omniauth(request.env['omniauth.auth'])

        requested_role = if request.env['omniauth.params'] && request.env['omniauth.params']['role']
                            request.env['omniauth.params']['role']
                          else
                            params[:role]
                          end

        if requested_role.present? && @user && @user.role.blank?
          allowed_roles = %w[customer seller admin]
          if allowed_roles.include?(requested_role)
            @user.update(role: requested_role)
          end
        end

        if @user.persisted?
          sign_in @user
          token = request.env['warden-jwt_auth.token']

          dashboard_path = case @user.role
                          when 'seller'
                            '/seller/setup'
                          else
                            '/client/dashboard'
                          end

          role_query = @user.role.present? ? "&role=#{CGI.escape(@user.role)}" : ''
          frontend_url = "http://localhost:3001#{dashboard_path}?token=#{token}#{role_query}"

          respond_to do |format|
            format.json do
              render json: {
                message: 'Signed in (developer)',
                user: @user,
                access_token: token,
                redirect_url: frontend_url
              }
            end

            format.html { redirect_to frontend_url }
          end
        else
          respond_to do |format|
            format.json { render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity }
            format.html { render plain: 'Authentication failed', status: :unauthorized }
          end
        end
      end

      # Developer callback (for omniauth developer strategy) moved inside
      # the controller so it is callable as an action during development.
      def developer
        @user = User.from_omniauth(request.env['omniauth.auth'])

        env_params = request.env['omniauth.params'] rescue nil
        session_params = session['omniauth.params'] || session[:omniauth_params]
        requested_role = if env_params && env_params['role']
                            env_params['role']
                          elsif params[:role].present?
                            params[:role]
                          elsif session_params && session_params['role']
                            session_params['role']
                          end

        Rails.logger.debug "Developer OmniAuth role sources: env=#{env_params.inspect}, params=#{params[:role].inspect}, session=#{session_params.inspect}, chosen=#{requested_role.inspect}"

        if requested_role.present? && @user && @user.role.blank?
          allowed_roles = %w[customer seller admin]
          if allowed_roles.include?(requested_role)
            @user.update(role: requested_role)
          end
        end

        if @user.persisted?
          sign_in @user
          token = request.env['warden-jwt_auth.token']

          dashboard_path = case @user.role
                          when 'seller'
                            '/seller/setup'
                          else
                            '/client/dashboard'
                          end

          role_query = @user.role.present? ? "&role=#{CGI.escape(@user.role)}" : ''
          frontend_url = "http://localhost:3001#{dashboard_path}?token=#{token}#{role_query}"

          respond_to do |format|
            format.json do
              render json: {
                message: 'Signed in (developer)',
                user: @user,
                access_token: token,
                redirect_url: frontend_url
              }
            end

            format.html { redirect_to frontend_url }
          end
        else
          respond_to do |format|
            format.json { render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity }
            format.html { render plain: 'Authentication failed', status: :unauthorized }
          end
        end
      end
    end
  end
end
