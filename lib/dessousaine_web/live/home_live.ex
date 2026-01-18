defmodule DessousaineWeb.HomeLive do
  @moduledoc """
  Page d'accueil avec les liens vers les différentes sections.
  """
  use DessousaineWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Dessousaine")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen flex items-center justify-center" style="background-color: #fdfdfe;">
      <div class="max-w-4xl mx-auto px-6 py-12">
        <!-- Header -->
        <div class="text-center mb-12">
          <h1 class="text-4xl font-bold text-gray-900 mb-2">Dessousaine</h1>
          <p class="text-gray-500">Découvrez Strasbourg autrement</p>
        </div>
        
    <!-- Cards -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
          <!-- CineDie Card -->
          <.link
            navigate={~p"/cinedie"}
            class="group bg-white rounded-2xl overflow-hidden border border-gray-200 hover:shadow-xl transition-all duration-300 hover:-translate-y-1"
          >
            <div class="aspect-video bg-gradient-to-br from-purple-500 to-indigo-600 flex items-center justify-center">
              <.icon
                name="hero-film"
                class="w-20 h-20 text-white/80 group-hover:scale-110 transition-transform"
              />
            </div>
            <div class="p-6">
              <h2 class="text-2xl font-bold text-gray-900 mb-2">CineDie</h2>
              <p class="text-gray-500">
                Les séances de cinéma de la semaine à Strasbourg
              </p>
              <div class="mt-4 flex items-center gap-2 text-indigo-600 font-medium">
                <span>Voir les séances</span>
                <.icon
                  name="hero-arrow-right"
                  class="w-4 h-4 group-hover:translate-x-1 transition-transform"
                />
              </div>
            </div>
          </.link>
          
    <!-- Samuser Card -->
          <.link
            navigate={~p"/samuser"}
            class="group bg-white rounded-2xl overflow-hidden border border-gray-200 hover:shadow-xl transition-all duration-300 hover:-translate-y-1"
          >
            <div
              class="aspect-video flex items-center justify-center"
              style="background: linear-gradient(135deg, #f25434 0%, #ff7b5a 100%);"
            >
              <.icon
                name="hero-building-library"
                class="w-20 h-20 text-white/80 group-hover:scale-110 transition-transform"
              />
            </div>
            <div class="p-6">
              <h2 class="text-2xl font-bold text-gray-900 mb-2">SaMuser</h2>
              <p class="text-gray-500">
                Les expositions des musées de Strasbourg
              </p>
              <div class="mt-4 flex items-center gap-2 font-medium" style="color: #f25434;">
                <span>Voir les expos</span>
                <.icon
                  name="hero-arrow-right"
                  class="w-4 h-4 group-hover:translate-x-1 transition-transform"
                />
              </div>
            </div>
          </.link>
        </div>
      </div>
    </div>
    """
  end
end
