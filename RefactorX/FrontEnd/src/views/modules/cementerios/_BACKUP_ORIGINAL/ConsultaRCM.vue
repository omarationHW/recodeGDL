<template>
  <div class="module-container">
    <div class="module-header">
      <h1 class="module-title">
        <i class="fas fa-search-location"></i>
        Consulta RCM por Número
      </h1>
      <DocumentationModal
        title="Ayuda - Consulta RCM"
        :sections="helpSections"
      />
    </div>

    <!-- Búsqueda -->
    <div class="card mb-3">
      <div class="card-header">
        <i class="fas fa-search"></i>
        Búsqueda de Control RCM
      </div>
      <div class="card-body">
        <div class="form-grid-two">
          <div class="form-group">
            <label class="form-label required">Número de Control RCM</label>
            <input
              v-model.number="controlRCM"
              type="number"
              class="form-control"
              placeholder="Ingrese número de control..."
              @keyup.enter="buscarRCM"
              autofocus
            />
          </div>
          <div class="form-actions">
            <button @click="buscarRCM" class="btn-municipal-primary">
              <i class="fas fa-search"></i>
              Buscar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Resultado -->
    <div v-if="folio" class="card">
      <div class="card-header">
        <i class="fas fa-info-circle"></i>
        Información del RCM {{ folio.control_rcm }}
      </div>
      <div class="card-body">
        <div class="rcm-info-grid">
          <div class="info-section">
            <h5><i class="fas fa-user"></i> Titular</h5>
            <p class="info-value">{{ folio.nombre }}</p>
          </div>
          <div class="info-section">
            <h5><i class="fas fa-map-marked-alt"></i> Cementerio</h5>
            <p class="info-value">{{ folio.cementerio_nombre || folio.cementerio }}</p>
          </div>
          <div class="info-section">
            <h5><i class="fas fa-map-pin"></i> Ubicación</h5>
            <p class="info-value">{{ formatearUbicacion(folio) }}</p>
          </div>
          <div class="info-section">
            <h5><i class="fas fa-calendar-alt"></i> Año Pagado</h5>
            <p class="info-value highlight">{{ folio.axo_pagado }}</p>
          </div>
        </div>

        <div class="form-actions mt-3">
          <button @click="verDetalleCompleto" class="btn-municipal-primary">
            <i class="fas fa-eye"></i>
            Ver Detalle Completo
          </button>
        </div>
      </div>
    </div>

    <div v-else-if="busquedaRealizada" class="alert-warning">
      <i class="fas fa-exclamation-triangle"></i>
      No se encontró el control RCM especificado
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import { useToast } from '@/composables/useToast'
import { useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const api = useApi()
const toast = useToast()
const router = useRouter()

const controlRCM = ref(null)
const folio = ref(null)
const busquedaRealizada = ref(false)

const helpSections = [
  {
    title: 'Consulta RCM por Número',
    content: `
      <p>Búsqueda rápida de folios por número de control RCM.</p>
      <h4>Uso:</h4>
      <ol>
        <li>Ingrese el número de control RCM</li>
        <li>Presione Enter o haga clic en "Buscar"</li>
        <li>Visualice la información básica</li>
        <li>Acceda al detalle completo si lo requiere</li>
      </ol>
    `
  }
]

const buscarRCM = async () => {
  if (!controlRCM.value || controlRCM.value <= 0) {
    toast.warning('Ingrese un número de control RCM válido')
    return
  }

  try {
    const response = await api.callStoredProcedure('SP_CEM_CONSULTAR_FOLIO', {
      p_control_rcm: controlRCM.value
    })

    busquedaRealizada.value = true

    if (response.data && response.data.length > 0) {
      const result = response.data[0]

      if (result.resultado === 'N') {
        folio.value = null
        toast.warning(result.mensaje)
        return
      }

      folio.value = result
      toast.success('RCM encontrado')
    } else {
      folio.value = null
      toast.warning('No se encontró el RCM')
    }
  } catch (error) {
    console.error('Error al buscar RCM:', error)
    toast.error('Error al buscar RCM')
    folio.value = null
  }
}

const verDetalleCompleto = () => {
  if (folio.value) {
    router.push({
      name: 'cementerios-conindividual',
      query: { folio: folio.value.control_rcm }
    })
  }
}

const formatearUbicacion = (folio) => {
  const partes = []
  partes.push(`Cl:${folio.clase}${folio.clase_alfa || ''}`)
  partes.push(`Sec:${folio.seccion}${folio.seccion_alfa || ''}`)
  partes.push(`Lin:${folio.linea}${folio.linea_alfa || ''}`)
  partes.push(`Fosa:${folio.fosa}${folio.fosa_alfa || ''}`)
  return partes.join(' ')
}
</script>

<style scoped>
.rcm-info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  margin-bottom: 1rem;
}

.info-section {
  padding: 1rem;
  background-color: var(--color-bg-secondary);
  border-radius: 0.375rem;
  border-left: 4px solid var(--color-primary);
}

.info-section h5 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.875rem;
  color: var(--color-text-secondary);
  margin-bottom: 0.5rem;
  text-transform: uppercase;
}

.info-value {
  font-size: 1.125rem;
  font-weight: 600;
  color: var(--color-text-primary);
  margin: 0;
}

.info-value.highlight {
  font-size: 1.5rem;
  color: var(--color-primary);
}
</style>
