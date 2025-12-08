<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="cross" />
      </div>
      <div class="module-view-info">
        <h1>Módulo de Cementerios</h1>
        <p>Sistema Municipal de Gestión de Cementerios</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-secondary"
          @click="mostrarDocumentacion"
          title="Documentacion Tecnica"
        >
          <font-awesome-icon icon="file-code" />
          Documentacion
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
          title="Ayuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    
    </div>

    <div class="module-view-content">
      <!-- Gestión de Datos -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="database" />
            Gestión de Datos
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="stats-grid">
            <router-link to="/cementerios/abcementer" class="stat-card">
              <div class="stat-icon">
                <font-awesome-icon icon="church" />
              </div>
              <div class="stat-label">ABC Cementerios</div>
            </router-link>
            <router-link to="/cementerios/abcfolio" class="stat-card">
              <div class="stat-icon">
                <font-awesome-icon icon="folder-open" />
              </div>
              <div class="stat-label">ABC Folios</div>
            </router-link>
            <router-link to="/cementerios/abcpagos" class="stat-card">
              <div class="stat-icon">
                <font-awesome-icon icon="dollar-sign" />
              </div>
              <div class="stat-label">ABC Pagos</div>
            </router-link>
            <router-link to="/cementerios/abcrecargos" class="stat-card">
              <div class="stat-icon">
                <font-awesome-icon icon="plus-circle" />
              </div>
              <div class="stat-label">ABC Recargos</div>
            </router-link>
          </div>
        </div>
      </div>

      <!-- Consultas -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Consultas
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="stats-grid">
            <router-link to="/cementerios/consultafol" class="stat-card">
              <div class="stat-icon">
                <font-awesome-icon icon="file-alt" />
              </div>
              <div class="stat-label">Consulta por Folio</div>
            </router-link>
            <router-link to="/cementerios/consultarcm" class="stat-card">
              <div class="stat-icon">
                <font-awesome-icon icon="search-location" />
              </div>
              <div class="stat-label">Consulta RCM</div>
            </router-link>
            <router-link to="/cementerios/consultanombre" class="stat-card">
              <div class="stat-icon">
                <font-awesome-icon icon="user-search" />
              </div>
              <div class="stat-label">Consulta por Nombre</div>
            </router-link>
            <router-link to="/cementerios/conindividual" class="stat-card">
              <div class="stat-icon">
                <font-awesome-icon icon="user-circle" />
              </div>
              <div class="stat-label">Consulta Individual</div>
            </router-link>
          </div>
        </div>
      </div>

      <!-- Consultas por Cementerio -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="map-marker-alt" />
            Consultas por Cementerio
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="stats-grid">
            <router-link to="/cementerios/consultaguad" class="stat-card">
              <div class="stat-icon">
                <font-awesome-icon icon="cross" />
              </div>
              <div class="stat-label">Guadalajara</div>
            </router-link>
            <router-link to="/cementerios/consultajardin" class="stat-card">
              <div class="stat-icon">
                <font-awesome-icon icon="leaf" />
              </div>
              <div class="stat-label">Jardín</div>
            </router-link>
            <router-link to="/cementerios/consultamezq" class="stat-card">
              <div class="stat-icon">
                <font-awesome-icon icon="church" />
              </div>
              <div class="stat-label">Mezquitán</div>
            </router-link>
            <router-link to="/cementerios/consultasandres" class="stat-card">
              <div class="stat-icon">
                <font-awesome-icon icon="monument" />
              </div>
              <div class="stat-label">San Andrés</div>
            </router-link>
          </div>
        </div>
      </div>

      <!-- Operaciones Especiales -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="cogs" />
            Operaciones Especiales
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="stats-grid">
            <router-link to="/cementerios/bonificaciones" class="stat-card">
              <div class="stat-icon">
                <font-awesome-icon icon="percentage" />
              </div>
              <div class="stat-label">Bonificaciones</div>
            </router-link>
            <router-link to="/cementerios/descuentos" class="stat-card">
              <div class="stat-icon">
                <font-awesome-icon icon="tags" />
              </div>
              <div class="stat-label">Descuentos</div>
            </router-link>
            <router-link to="/cementerios/duplicados" class="stat-card">
              <div class="stat-icon">
                <font-awesome-icon icon="copy" />
              </div>
              <div class="stat-label">Duplicados</div>
            </router-link>
            <router-link to="/cementerios/traslados" class="stat-card">
              <div class="stat-icon">
                <font-awesome-icon icon="arrows-alt" />
              </div>
              <div class="stat-label">Traslados</div>
            </router-link>
          </div>
        </div>
      </div>

      <!-- Títulos y Liquidaciones -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="file-contract" />
            Títulos y Liquidaciones
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="stats-grid">
            <router-link to="/cementerios/titulos" class="stat-card">
              <div class="stat-icon">
                <font-awesome-icon icon="certificate" />
              </div>
              <div class="stat-label">Títulos</div>
            </router-link>
            <router-link to="/cementerios/titulossin" class="stat-card">
              <div class="stat-icon">
                <font-awesome-icon icon="file-signature" />
              </div>
              <div class="stat-label">Generar Títulos</div>
            </router-link>
            <router-link to="/cementerios/liquidaciones" class="stat-card">
              <div class="stat-icon">
                <font-awesome-icon icon="calculator" />
              </div>
              <div class="stat-label">Liquidaciones</div>
            </router-link>
          </div>
        </div>
      </div>

      <!-- Reportes y Estadísticas -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="chart-bar" />
            Reportes y Estadísticas
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="stats-grid">
            <router-link to="/cementerios/estad-adeudo" class="stat-card">
              <div class="stat-icon">
                <font-awesome-icon icon="chart-line" />
              </div>
              <div class="stat-label">Estadísticas Adeudos</div>
            </router-link>
            <router-link to="/cementerios/rep-a-cobrar" class="stat-card">
              <div class="stat-icon">
                <font-awesome-icon icon="file-invoice-dollar" />
              </div>
              <div class="stat-label">Cuentas por Cobrar</div>
            </router-link>
            <router-link to="/cementerios/rep-bon" class="stat-card">
              <div class="stat-icon">
                <font-awesome-icon icon="percent" />
              </div>
              <div class="stat-label">Reporte Bonificaciones</div>
            </router-link>
            <router-link to="/cementerios/rpttitulos" class="stat-card">
              <div class="stat-icon">
                <font-awesome-icon icon="file-pdf" />
              </div>
              <div class="stat-label">Reporte Títulos</div>
            </router-link>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - Menu"
    >
      <h3>Menu</h3>
      <p>Documentacion del modulo Cementerios.</p>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Menu'"
      :moduleName="'cementerios'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

onMounted(() => {
  // Lifecycle hook
})

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>
