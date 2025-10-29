<template>
  <div class="module-container">
    <div class="module-header">
      <h1 class="module-title">
        <i class="fas fa-exchange-alt"></i>
        Traslado de Folios sin Número
      </h1>
      <DocumentationModal
        title="Ayuda - Traslado de Folios"
        :sections="helpSections"
      />
    </div>

    <!-- Folio Origen -->
    <div class="card mb-3">
      <div class="card-header">
        <i class="fas fa-file-export"></i>
        Folio de Origen
      </div>
      <div class="card-body">
        <div class="form-grid-two">
          <div class="form-group">
            <label class="form-label required">Número de Folio Origen</label>
            <input
              v-model.number="folioOrigen"
              type="number"
              class="form-control"
              @keyup.enter="buscarFolioOrigen"
            />
          </div>
          <div class="form-actions">
            <button @click="buscarFolioOrigen" class="btn-municipal-primary">
              <i class="fas fa-search"></i>
              Buscar
            </button>
          </div>
        </div>

        <div v-if="datosOrigen" class="folio-info mt-3">
          <h5>Información del Folio Origen</h5>
          <div class="info-grid">
            <div class="info-item">
              <label>Titular:</label>
              <span>{{ datosOrigen.nombre }}</span>
            </div>
            <div class="info-item">
              <label>Cementerio:</label>
              <span>{{ datosOrigen.cementerio }}</span>
            </div>
            <div class="info-item">
              <label>Ubicación:</label>
              <span>{{ formatearUbicacion(datosOrigen) }}</span>
            </div>
            <div class="info-item">
              <label>Año Pagado:</label>
              <span class="highlight">{{ datosOrigen.axo_pagado }}</span>
            </div>
            <div class="info-item">
              <label>Metros:</label>
              <span>{{ datosOrigen.metros }} m²</span>
            </div>
            <div class="info-item">
              <label>Tipo:</label>
              <span>{{ datosOrigen.tipo }}</span>
            </div>
          </div>

          <!-- Pagos del Folio Origen -->
          <div v-if="pagosOrigen.length > 0" class="mt-3">
            <h6><i class="fas fa-list"></i> Pagos Registrados ({{ pagosOrigen.length }})</h6>
            <div class="table-responsive">
              <table class="data-table">
                <thead>
                  <tr>
                    <th>Año</th>
                    <th>Fecha</th>
                    <th>Importe</th>
                    <th>Recargos</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="pago in pagosOrigen" :key="pago.control_id">
                    <td>{{ pago.axo_pago_desde }} - {{ pago.axo_pago_hasta }}</td>
                    <td>{{ formatearFecha(pago.fecing) }}</td>
                    <td>${{ formatearMoneda(pago.importe_anual) }}</td>
                    <td>${{ formatearMoneda(pago.importe_recargos) }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Folio Destino -->
    <div v-if="datosOrigen" class="card mb-3">
      <div class="card-header">
        <i class="fas fa-file-import"></i>
        Folio de Destino
      </div>
      <div class="card-body">
        <div class="form-grid-two">
          <div class="form-group">
            <label class="form-label required">Número de Folio Destino</label>
            <input
              v-model.number="folioDestino"
              type="number"
              class="form-control"
              @keyup.enter="buscarFolioDestino"
            />
          </div>
          <div class="form-actions">
            <button @click="buscarFolioDestino" class="btn-municipal-primary">
              <i class="fas fa-search"></i>
              Buscar
            </button>
          </div>
        </div>

        <div v-if="datosDestino" class="folio-info mt-3">
          <h5>Información del Folio Destino</h5>
          <div class="info-grid">
            <div class="info-item">
              <label>Titular:</label>
              <span>{{ datosDestino.nombre }}</span>
            </div>
            <div class="info-item">
              <label>Cementerio:</label>
              <span>{{ datosDestino.cementerio }}</span>
            </div>
            <div class="info-item">
              <label>Ubicación:</label>
              <span>{{ formatearUbicacion(datosDestino) }}</span>
            </div>
            <div class="info-item">
              <label>Año Pagado:</label>
              <span class="highlight">{{ datosDestino.axo_pagado }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Opciones de Traslado -->
    <div v-if="datosOrigen && datosDestino" class="card">
      <div class="card-header">
        <i class="fas fa-tasks"></i>
        Opciones de Traslado
      </div>
      <div class="card-body">
        <div class="form-group">
          <div class="checkbox-group">
            <label class="checkbox-label">
              <input type="checkbox" v-model="opcionesTraslado.trasladarPagos" />
              <span>Trasladar Pagos del Folio Origen al Destino</span>
            </label>
          </div>
          <div class="checkbox-group">
            <label class="checkbox-label">
              <input type="checkbox" v-model="opcionesTraslado.trasladarDatos" />
              <span>Trasladar Datos del Titular (Nombre y Domicilio)</span>
            </label>
          </div>
        </div>

        <div class="form-group">
          <label class="form-label">Observaciones del Traslado</label>
          <textarea
            v-model="opcionesTraslado.observaciones"
            class="form-control"
            rows="3"
            maxlength="255"
            placeholder="Motivo o detalles del traslado..."
          ></textarea>
        </div>

        <div class="alert-warning mb-3">
          <i class="fas fa-exclamation-triangle"></i>
          <strong>Advertencia:</strong> El traslado es una operación delicada. Verifique cuidadosamente
          los folios de origen y destino antes de continuar.
        </div>

        <div class="form-actions">
          <button @click="ejecutarTraslado" class="btn-municipal-primary">
            <i class="fas fa-exchange-alt"></i>
            Ejecutar Traslado
          </button>
          <button @click="limpiar" class="btn-municipal-secondary">
            <i class="fas fa-times"></i>
            Cancelar
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useApi } from '@/composables/useApi'
import { useToast } from '@/composables/useToast'
import Swal from 'sweetalert2'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const api = useApi()
const toast = useToast()

const folioOrigen = ref(null)
const folioDestino = ref(null)
const datosOrigen = ref(null)
const datosDestino = ref(null)
const pagosOrigen = ref([])

const opcionesTraslado = reactive({
  trasladarPagos: true,
  trasladarDatos: false,
  observaciones: ''
})

const helpSections = [
  {
    title: 'Traslado de Folios sin Número',
    content: `
      <p>Permite trasladar información de un folio a otro sin asignar un número de operación específico.</p>
      <h4>Proceso:</h4>
      <ol>
        <li>Buscar y verificar el folio de origen</li>
        <li>Buscar y verificar el folio de destino</li>
        <li>Seleccionar qué información trasladar:
          <ul>
            <li><strong>Pagos:</strong> Transfiere todos los pagos al nuevo folio</li>
            <li><strong>Datos del Titular:</strong> Copia nombre y domicilio</li>
          </ul>
        </li>
        <li>Ejecutar el traslado</li>
      </ol>
      <h4>Advertencia:</h4>
      <p>Esta operación es delicada y debe realizarse con precaución. Verifique siempre
      que los folios sean correctos antes de ejecutar el traslado.</p>
    `
  }
]

const buscarFolioOrigen = async () => {
  if (!folioOrigen.value) {
    toast.warning('Ingrese un número de folio origen')
    return
  }

  try {
    const response = await api.callStoredProcedure('SP_CEM_CONSULTAR_FOLIO', {
      p_control_rcm: folioOrigen.value
    })

    if (response.data && response.data.length > 0) {
      const result = response.data[0]

      if (result.resultado === 'N') {
        datosOrigen.value = null
        toast.warning(result.mensaje)
        return
      }

      datosOrigen.value = result
      await cargarPagosOrigen()
      toast.success('Folio origen encontrado')
    } else {
      datosOrigen.value = null
      toast.warning('No se encontró el folio origen')
    }
  } catch (error) {
    console.error('Error al buscar folio origen:', error)
    toast.error('Error al buscar folio origen')
    datosOrigen.value = null
  }
}

const buscarFolioDestino = async () => {
  if (!folioDestino.value) {
    toast.warning('Ingrese un número de folio destino')
    return
  }

  if (folioDestino.value === folioOrigen.value) {
    toast.warning('El folio destino no puede ser igual al folio origen')
    return
  }

  try {
    const response = await api.callStoredProcedure('SP_CEM_CONSULTAR_FOLIO', {
      p_control_rcm: folioDestino.value
    })

    if (response.data && response.data.length > 0) {
      const result = response.data[0]

      if (result.resultado === 'N') {
        datosDestino.value = null
        toast.warning(result.mensaje)
        return
      }

      datosDestino.value = result
      toast.success('Folio destino encontrado')
    } else {
      datosDestino.value = null
      toast.warning('No se encontró el folio destino')
    }
  } catch (error) {
    console.error('Error al buscar folio destino:', error)
    toast.error('Error al buscar folio destino')
    datosDestino.value = null
  }
}

const cargarPagosOrigen = async () => {
  try {
    const response = await api.callStoredProcedure('SP_CEM_LISTAR_PAGOS', {
      p_control_rcm: folioOrigen.value
    })

    pagosOrigen.value = response.data || []
  } catch (error) {
    console.error('Error al cargar pagos origen:', error)
    pagosOrigen.value = []
  }
}

const ejecutarTraslado = async () => {
  if (!opcionesTraslado.trasladarPagos && !opcionesTraslado.trasladarDatos) {
    toast.warning('Seleccione al menos una opción de traslado')
    return
  }

  const result = await Swal.fire({
    title: '¿Confirmar Traslado?',
    html: `
      <p>¿Está seguro de trasladar información del folio <strong>${folioOrigen.value}</strong>
      al folio <strong>${folioDestino.value}</strong>?</p>
      <p><strong>Opciones seleccionadas:</strong></p>
      <ul style="text-align: left;">
        ${opcionesTraslado.trasladarPagos ? '<li>Trasladar Pagos</li>' : ''}
        ${opcionesTraslado.trasladarDatos ? '<li>Trasladar Datos del Titular</li>' : ''}
      </ul>
    `,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, trasladar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#d33'
  })

  if (result.isConfirmed) {
    try {
      const response = await api.callStoredProcedure('SP_CEM_TRASLADAR_FOLIO', {
        p_folio_origen: folioOrigen.value,
        p_folio_destino: folioDestino.value,
        p_trasladar_pagos: opcionesTraslado.trasladarPagos ? 1 : 0,
        p_trasladar_datos: opcionesTraslado.trasladarDatos ? 1 : 0,
        p_observaciones: opcionesTraslado.observaciones || '',
        p_usuario: 1
      })

      if (response.data && response.data[0]?.resultado === 'S') {
        toast.success('Traslado ejecutado exitosamente')
        limpiar()
      } else {
        toast.error(response.data[0]?.mensaje || 'Error al ejecutar traslado')
      }
    } catch (error) {
      console.error('Error al ejecutar traslado:', error)
      toast.error('Error al ejecutar traslado')
    }
  }
}

const limpiar = () => {
  folioOrigen.value = null
  folioDestino.value = null
  datosOrigen.value = null
  datosDestino.value = null
  pagosOrigen.value = []
  opcionesTraslado.trasladarPagos = true
  opcionesTraslado.trasladarDatos = false
  opcionesTraslado.observaciones = ''
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

const formatearMoneda = (valor) => {
  if (!valor) return '0.00'
  return parseFloat(valor).toFixed(2)
}
</script>

<style scoped>
.folio-info {
  padding: 1rem;
  background-color: var(--color-bg-secondary);
  border-radius: 0.375rem;
  border-left: 4px solid var(--color-primary);
}

.folio-info h5 {
  margin-bottom: 1rem;
  color: var(--color-primary);
}

.folio-info h6 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
  font-size: 0.95rem;
  color: var(--color-text-secondary);
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.info-item label {
  font-size: 0.875rem;
  color: var(--color-text-secondary);
  font-weight: 500;
}

.info-item span {
  font-size: 1rem;
  color: var(--color-text-primary);
  font-weight: 600;
}

.info-item span.highlight {
  color: var(--color-primary);
  font-size: 1.25rem;
}

.checkbox-group {
  margin-bottom: 0.75rem;
}

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
  font-size: 1rem;
}

.checkbox-label input[type="checkbox"] {
  width: 1.25rem;
  height: 1.25rem;
  cursor: pointer;
}

.checkbox-label span {
  user-select: none;
}
</style>
