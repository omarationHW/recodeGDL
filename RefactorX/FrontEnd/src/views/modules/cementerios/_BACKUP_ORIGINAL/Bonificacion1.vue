<template>
  <div class="module-container">
    <div class="module-header">
      <h1 class="module-title">
        <i class="fas fa-file-signature"></i>
        Bonificaciones Especiales con Oficio
      </h1>
      <DocumentationModal
        title="Ayuda - Bonificaciones con Oficio"
        :sections="helpSections"
      />
    </div>

    <!-- Búsqueda de Folio -->
    <div class="card mb-3">
      <div class="card-header">
        <i class="fas fa-search"></i>
        Buscar Folio
      </div>
      <div class="card-body">
        <div class="form-grid-two">
          <div class="form-group">
            <label class="form-label required">Número de Folio</label>
            <input
              v-model.number="folioABuscar"
              type="number"
              class="form-control"
              @keyup.enter="buscarFolio"
              autofocus
            />
          </div>
          <div class="form-actions">
            <button @click="buscarFolio" class="btn-municipal-primary">
              <i class="fas fa-search"></i>
              Buscar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Información del Folio -->
    <div v-if="folio" class="card mb-3">
      <div class="card-header">
        <i class="fas fa-info-circle"></i>
        Información del Folio {{ folio.control_rcm }}
      </div>
      <div class="card-body">
        <div class="folio-info-grid">
          <div class="info-group">
            <label>Titular:</label>
            <span class="info-value">{{ folio.nombre }}</span>
          </div>
          <div class="info-group">
            <label>Cementerio:</label>
            <span class="info-value">{{ folio.cementerio }}</span>
          </div>
          <div class="info-group">
            <label>Ubicación:</label>
            <span class="info-value">{{ formatearUbicacion(folio) }}</span>
          </div>
          <div class="info-group">
            <label>Año Pagado:</label>
            <span class="info-value highlight">{{ folio.axo_pagado }}</span>
          </div>
          <div class="info-group">
            <label>Metros:</label>
            <span class="info-value">{{ folio.metros }} m²</span>
          </div>
          <div class="info-group">
            <label>Tipo:</label>
            <span class="info-value">{{ folio.tipo }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Formulario de Bonificación con Oficio -->
    <div v-if="folio" class="card">
      <div class="card-header">
        <i class="fas fa-percentage"></i>
        Aplicar Bonificación Especial
      </div>
      <div class="card-body">
        <div class="form-grid-three">
          <div class="form-group">
            <label class="form-label required">Número de Oficio</label>
            <input
              v-model.number="bonificacion.numero_oficio"
              type="number"
              class="form-control"
              min="1"
            />
          </div>
          <div class="form-group">
            <label class="form-label required">Año Desde</label>
            <input
              v-model.number="bonificacion.anio_desde"
              type="number"
              class="form-control"
              :min="2000"
              :max="new Date().getFullYear()"
            />
          </div>
          <div class="form-group">
            <label class="form-label">Porcentaje de Bonificación (%)</label>
            <input
              v-model.number="bonificacion.porcentaje"
              type="number"
              class="form-control"
              min="0"
              max="100"
              step="0.01"
            />
          </div>
        </div>
        <div class="form-group">
          <label class="form-label">Observaciones</label>
          <textarea
            v-model="bonificacion.observaciones"
            class="form-control"
            rows="3"
            maxlength="255"
          ></textarea>
        </div>
        <div class="form-actions">
          <button @click="aplicarBonificacion" class="btn-municipal-primary">
            <i class="fas fa-save"></i>
            Aplicar Bonificación
          </button>
          <button @click="limpiar" class="btn-municipal-secondary">
            <i class="fas fa-eraser"></i>
            Limpiar
          </button>
        </div>
      </div>
    </div>

    <!-- Historial de Bonificaciones con Oficio -->
    <div v-if="folio && bonificaciones.length > 0" class="card mt-3">
      <div class="card-header">
        <i class="fas fa-history"></i>
        Historial de Bonificaciones con Oficio
      </div>
      <div class="card-body">
        <div class="table-responsive">
          <table class="data-table">
            <thead>
              <tr>
                <th>Oficio</th>
                <th>Año Desde</th>
                <th>Porcentaje</th>
                <th>Fecha Aplicación</th>
                <th>Observaciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="bon in bonificaciones" :key="bon.id_bonificacion">
                <td>{{ bon.numero_oficio }}</td>
                <td>{{ bon.anio_desde }}</td>
                <td>{{ bon.porcentaje }}%</td>
                <td>{{ formatearFecha(bon.fecha_mov) }}</td>
                <td>{{ bon.observaciones }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useApi } from '@/composables/useApi'
import { useToast } from '@/composables/useToast'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const api = useApi()
const toast = useToast()

const folioABuscar = ref(null)
const folio = ref(null)
const bonificaciones = ref([])

const bonificacion = reactive({
  numero_oficio: null,
  anio_desde: new Date().getFullYear(),
  porcentaje: 0,
  observaciones: ''
})

const helpSections = [
  {
    title: 'Bonificaciones Especiales con Oficio',
    content: `
      <p>Gestión de bonificaciones especiales autorizadas mediante oficio oficial.</p>
      <h4>Características:</h4>
      <ul>
        <li><strong>Número de Oficio:</strong> Documento que autoriza la bonificación</li>
        <li><strong>Año Desde:</strong> A partir de qué año aplica la bonificación</li>
        <li><strong>Porcentaje:</strong> Porcentaje de bonificación autorizado</li>
      </ul>
      <p>Este tipo de bonificaciones requiere autorización oficial y queda registrada en el historial del folio.</p>
    `
  }
]

const buscarFolio = async () => {
  if (!folioABuscar.value) {
    toast.warning('Ingrese un número de folio')
    return
  }

  try {
    const response = await api.callStoredProcedure('SP_CEM_CONSULTAR_FOLIO', {
      p_control_rcm: folioABuscar.value
    })

    if (response.data && response.data.length > 0) {
      const result = response.data[0]

      if (result.resultado === 'N') {
        folio.value = null
        toast.warning(result.mensaje)
        return
      }

      folio.value = result
      await cargarBonificaciones()
      toast.success('Folio encontrado')
    } else {
      folio.value = null
      toast.warning('No se encontró el folio')
    }
  } catch (error) {
    console.error('Error al buscar folio:', error)
    toast.error('Error al buscar folio')
    folio.value = null
  }
}

const cargarBonificaciones = async () => {
  try {
    const response = await api.callStoredProcedure('SP_CEM_BONIFICACIONES_OFICIO', {
      p_operacion: 3,
      p_control_rcm: folioABuscar.value,
      p_numero_oficio: 0,
      p_anio_desde: 0,
      p_porcentaje: 0,
      p_observaciones: '',
      p_usuario: 1
    })

    bonificaciones.value = response.data || []
  } catch (error) {
    console.error('Error al cargar bonificaciones:', error)
    bonificaciones.value = []
  }
}

const aplicarBonificacion = async () => {
  if (!bonificacion.numero_oficio || !bonificacion.anio_desde) {
    toast.warning('Complete los campos requeridos: Número de Oficio y Año Desde')
    return
  }

  if (bonificacion.porcentaje < 0 || bonificacion.porcentaje > 100) {
    toast.warning('El porcentaje debe estar entre 0 y 100')
    return
  }

  try {
    const response = await api.callStoredProcedure('SP_CEM_BONIFICACIONES_OFICIO', {
      p_operacion: 1,
      p_control_rcm: folioABuscar.value,
      p_numero_oficio: bonificacion.numero_oficio,
      p_anio_desde: bonificacion.anio_desde,
      p_porcentaje: bonificacion.porcentaje,
      p_observaciones: bonificacion.observaciones || '',
      p_usuario: 1
    })

    if (response.data && response.data[0]?.resultado === 'S') {
      toast.success('Bonificación aplicada exitosamente')
      bonificacion.numero_oficio = null
      bonificacion.anio_desde = new Date().getFullYear()
      bonificacion.porcentaje = 0
      bonificacion.observaciones = ''
      await cargarBonificaciones()
    } else {
      toast.error(response.data[0]?.mensaje || 'Error al aplicar bonificación')
    }
  } catch (error) {
    console.error('Error al aplicar bonificación:', error)
    toast.error('Error al aplicar bonificación')
  }
}

const limpiar = () => {
  folioABuscar.value = null
  folio.value = null
  bonificaciones.value = []
  bonificacion.numero_oficio = null
  bonificacion.anio_desde = new Date().getFullYear()
  bonificacion.porcentaje = 0
  bonificacion.observaciones = ''
}

const formatearUbicacion = (folio) => {
  const partes = []
  partes.push(`Cl:${folio.clase}${folio.clase_alfa || ''}`)
  partes.push(`Sec:${folio.seccion}${folio.seccion_alfa || ''}`)
  partes.push(`Lin:${folio.linea}${folio.linea_alfa || ''}`)
  partes.push(`Fosa:${folio.fosa}${folio.fosa_alfa || ''}`)
  return partes.join(' ')
}

const formatearFecha = (fecha) => {
  if (!fecha) return '-'
  return new Date(fecha).toLocaleDateString('es-MX')
}
</script>

<style scoped>
/* Layout único de información de folio - Justificado mantener scoped */
.folio-info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin-bottom: 1rem;
}

.info-group {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.info-group label {
  font-size: 0.875rem;
  color: var(--color-text-secondary);
  font-weight: 500;
}

.info-value {
  font-size: 1rem;
  color: var(--color-text-primary);
  font-weight: 600;
}

.info-value.highlight {
  color: var(--color-primary);
  font-size: 1.25rem;
}
</style>
