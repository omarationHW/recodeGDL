<template>
  <div class="module-dashboard">
        <!-- Header -->
        <div class="dashboard-header">
          <h1>
            <font-awesome-icon icon="id-card" />
            Padrón de Licencias
          </h1>
          <p>Sistema integral de gestión de licencias comerciales y anuncios publicitarios</p>
        </div>

        <!-- Accesos Rápidos -->
        <div class="quick-access-grid">
          <!-- Consultas -->
          <div class="quick-access-card">
            <div class="card-icon consultas">
              <font-awesome-icon icon="search" />
            </div>
            <h3>Consultas</h3>
            <p>Búsqueda de usuarios, trámites y licencias</p>
            <div class="card-links">
              <router-link to="/padron-licencias/consulta-usuarios">Usuarios</router-link>
              <router-link to="/padron-licencias/consulta-tramites">Trámites</router-link>
              <router-link to="/padron-licencias/consulta-licencias">Licencias</router-link>
              <router-link to="/padron-licencias/consulta-anuncios">Anuncios</router-link>
            </div>
          </div>

          <!-- Trámites ✅ COMPLETO -->
          <div class="quick-access-card">
            <div class="card-icon tramites">
              <font-awesome-icon icon="file-signature" />
            </div>
            <h3>Trámites ✅</h3>
            <p>Gestión completa de trámites</p>
            <div class="card-links">
              <router-link to="/padron-licencias/modificacion-tramites">Modificar</router-link>
              <router-link to="/padron-licencias/cancelacion-tramites">Cancelar</router-link>
              <router-link to="/padron-licencias/reactivar-tramite">Reactivar</router-link>
              <router-link to="/padron-licencias/bloquear-tramite">Bloquear/Desbloquear</router-link>
              <router-link to="/padron-licencias/documentos-tramite">Documentos</router-link>
              <router-link to="/padron-licencias/tramite-baja-licencia">Baja Licencia</router-link>
              <router-link to="/padron-licencias/tramite-baja-anuncio">Baja Anuncio</router-link>
            </div>
          </div>

          <!-- Licencias -->
          <div class="quick-access-card">
            <div class="card-icon licencias">
              <font-awesome-icon icon="id-card" />
            </div>
            <h3>Licencias</h3>
            <p>Administración de licencias comerciales</p>
            <div class="card-links">
              <router-link to="/padron-licencias/modificacion-licencias">Modificar</router-link>
              <router-link to="/padron-licencias/baja-licencia">Dar de Baja</router-link>
              <router-link to="/padron-licencias/bloquear-licencia">Bloquear/Desbloquear</router-link>
              <router-link to="/padron-licencias/licencias-vigentes">Vigentes</router-link>
              <router-link to="/padron-licencias/licencias-adeudo">Con Adeudo</router-link>
              <router-link to="/padron-licencias/grupos-licencias">Grupos</router-link>
              <router-link to="/padron-licencias/zona-licencia">Zonificación</router-link>
            </div>
          </div>

          <!-- Anuncios -->
          <div class="quick-access-card">
            <div class="card-icon anuncios">
              <font-awesome-icon icon="bullhorn" />
            </div>
            <h3>Anuncios</h3>
            <p>Gestión de anuncios publicitarios</p>
            <div class="card-links">
              <router-link to="/padron-licencias/baja-anuncio">Dar de Baja</router-link>
              <router-link to="/padron-licencias/bloquear-anuncio">Bloquear/Desbloquear</router-link>
              <router-link to="/padron-licencias/liga-anuncio">Ligar Anuncio</router-link>
              <router-link to="/padron-licencias/grupos-anuncios">Grupos</router-link>
              <router-link to="/padron-licencias/zona-anuncio">Zonificación</router-link>
              <router-link to="/padron-licencias/reporte-anuncios-excel">Reporte Excel</router-link>
            </div>
          </div>

          <!-- Servicios -->
          <div class="quick-access-card">
            <div class="card-icon servicios">
              <font-awesome-icon icon="concierge-bell" />
            </div>
            <h3>Servicios</h3>
            <p>Emisión de documentos y certificaciones</p>
            <div class="card-links">
              <router-link to="/padron-licencias/constancias">Constancias</router-link>
              <router-link to="/padron-licencias/certificaciones">Certificaciones</router-link>
              <router-link to="/padron-licencias/dictamen-uso-suelo">Dictámenes</router-link>
              <router-link to="/padron-licencias/registro-solicitud">Registro Solicitud</router-link>
            </div>
          </div>

          <!-- Catálogos -->
          <div class="quick-access-card">
            <div class="card-icon catalogos">
              <font-awesome-icon icon="list" />
            </div>
            <h3>Catálogos</h3>
            <p>Administración de catálogos del sistema</p>
            <div class="card-links">
              <router-link to="/padron-licencias/catalogo-giros">Giros</router-link>
              <router-link to="/padron-licencias/catalogo-actividades">Actividades</router-link>
              <router-link to="/padron-licencias/empresas">Empresas</router-link>
              <router-link to="/padron-licencias/dependencias">Dependencias</router-link>
              <router-link to="/padron-licencias/estatus">Estatus</router-link>
            </div>
          </div>
        </div>

        <!-- Estadísticas Rápidas -->
        <div class="stats-summary">
          <div class="stat-item">
            <font-awesome-icon icon="file-alt" />
            <div>
              <span class="stat-value">{{ stats.tramites }}</span>
              <span class="stat-label">Trámites Activos</span>
            </div>
          </div>
          <div class="stat-item">
            <font-awesome-icon icon="id-badge" />
            <div>
              <span class="stat-value">{{ stats.licencias }}</span>
              <span class="stat-label">Licencias Vigentes</span>
            </div>
          </div>
          <div class="stat-item">
            <font-awesome-icon icon="check-circle" />
            <div>
              <span class="stat-value">{{ stats.completados }}</span>
              <span class="stat-label">Completados Hoy</span>
            </div>
          </div>
          <div class="stat-item">
            <font-awesome-icon icon="clock" />
            <div>
              <span class="stat-value">{{ stats.pendientes }}</span>
              <span class="stat-label">Pendientes</span>
            </div>
          </div>
        </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'index'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
</template>

<script setup>
import { ref } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

// Estadísticas de ejemplo (puedes conectar con API real)
const stats = ref({
  tramites: '1,245',
  licencias: '3,892',
  completados: '47',
  pendientes: '123'
})
</script>

<style scoped>
.module-dashboard {
  max-width: 1400px;
  margin: 0 auto;
  padding: 2rem;
  min-height: 100vh;
  background: #f9fafb;
}

.dashboard-header {
  margin-bottom: 2rem;
}

.dashboard-header h1 {
  font-size: 2rem;
  color: #111827;
  margin-bottom: 0.5rem;
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.dashboard-header p {
  color: #6b7280;
  font-size: 1rem;
}

.quick-access-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.quick-access-card {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s, box-shadow 0.2s;
}

.quick-access-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.card-icon {
  width: 60px;
  height: 60px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.75rem;
  color: white;
  margin-bottom: 1rem;
}

.card-icon.consultas {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
}

.card-icon.tramites {
  background: linear-gradient(135deg, #9363CD 0%, #7B47B8 100%);
}

.card-icon.licencias {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
}

.card-icon.servicios {
  background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
}

.card-icon.anuncios {
  background: linear-gradient(135deg, #ec4899 0%, #db2777 100%);
}

.card-icon.catalogos {
  background: linear-gradient(135deg, #6366f1 0%, #4f46e5 100%);
}

.quick-access-card h3 {
  font-size: 1.25rem;
  color: #111827;
  margin-bottom: 0.5rem;
}

.quick-access-card p {
  color: #6b7280;
  font-size: 0.875rem;
  margin-bottom: 1rem;
}

.card-links {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.card-links a {
  color: #9363CD;
  text-decoration: none;
  font-size: 0.875rem;
  font-weight: 500;
  transition: color 0.2s;
  padding: 0.375rem 0;
}

.card-links a:hover {
  color: #7B47B8;
  text-decoration: underline;
}

.stats-summary {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.stat-item svg {
  font-size: 2rem;
  color: #9363CD;
}

.stat-item div {
  display: flex;
  flex-direction: column;
}

.stat-value {
  font-size: 1.5rem;
  font-weight: 700;
  color: #111827;
}

.stat-label {
  font-size: 0.75rem;
  color: #6b7280;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

@media (max-width: 768px) {
  .module-dashboard {
    padding: 1rem;
  }

  .dashboard-header h1 {
    font-size: 1.5rem;
  }

  .quick-access-grid {
    grid-template-columns: 1fr;
  }

  .stats-summary {
    grid-template-columns: 1fr 1fr;
  }
}
</style>

