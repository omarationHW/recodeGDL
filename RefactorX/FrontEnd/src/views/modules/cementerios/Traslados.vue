<template>
  <div class="module-view">
    <!-- Header -->
    <div class="module-view-header">
      <div class="module-title-section">
        <font-awesome-icon icon="map-marked-alt module-icon" />
        <div>
          <h1 class="module-view-info">Traslados por Ubicación</h1>
          <p class="module-subtitle">Traslado de pagos entre ubicaciones físicas</p>
        </div>
      </div>
      <div class="module-actions">
        <button class="btn-help" @click="mostrarAyuda = true">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <!-- Ubicaciones -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <font-awesome-icon icon="map-pin" />
        Ubicaciones Físicas
      </div>
      <div class="municipal-card-body">
        <div class="ubicaciones-grid">
          <!-- Ubicación Origen -->
          <div class="ubicacion-form">
            <h3 class="ubicacion-title origin">
              <font-awesome-icon icon="arrow-right" />
              Ubicación Origen
            </h3>

            <div class="form-group">
              <label class="form-label required">Cementerio</label>
              <select v-model="origen.cementerio" class="form-input">
                <option value="">-- Seleccione --</option>
                <option v-for="cem in cementerios" :key="cem.cementerio" :value="cem.cementerio">
                  {{ cem.cementerio }} - {{ cem.nombre }}
                </option>
              </select>
            </div>

            <div class="form-grid-two">
              <div class="form-group">
                <label class="form-label required">Clase</label>
                <input type="number" v-model.number="origen.clase" class="form-input" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Clase Alfa</label>
                <input v-model="origen.clase_alfa" class="form-input" maxlength="2" />
              </div>
            </div>

            <div class="form-grid-two">
              <div class="form-group">
                <label class="form-label required">Sección</label>
                <input type="number" v-model.number="origen.seccion" class="form-input" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Sección Alfa</label>
                <input v-model="origen.seccion_alfa" class="form-input" maxlength="2" />
              </div>
            </div>

            <div class="form-grid-two">
              <div class="form-group">
                <label class="form-label required">Línea</label>
                <input type="number" v-model.number="origen.linea" class="form-input" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Línea Alfa</label>
                <input v-model="origen.linea_alfa" class="form-input" maxlength="2" />
              </div>
            </div>

            <div class="form-grid-two">
              <div class="form-group">
                <label class="form-label required">Fosa</label>
                <input type="number" v-model.number="origen.fosa" class="form-input" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Fosa Alfa</label>
                <input v-model="origen.fosa_alfa" class="form-input" maxlength="4" />
              </div>
            </div>
          </div>

          <div class="transfer-arrow">
            <font-awesome-icon icon="arrow-circle-right" />
          </div>

          <!-- Ubicación Destino -->
          <div class="ubicacion-form">
            <h3 class="ubicacion-title destination">
              <font-awesome-icon icon="arrow-left" />
              Ubicación Destino
            </h3>

            <div class="form-group">
              <label class="form-label required">Cementerio</label>
              <select v-model="destino.cementerio" class="form-input">
                <option value="">-- Seleccione --</option>
                <option v-for="cem in cementerios" :key="cem.cementerio" :value="cem.cementerio">
                  {{ cem.cementerio }} - {{ cem.nombre }}
                </option>
              </select>
            </div>

            <div class="form-grid-two">
              <div class="form-group">
                <label class="form-label required">Clase</label>
                <input type="number" v-model.number="destino.clase" class="form-input" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Clase Alfa</label>
                <input v-model="destino.clase_alfa" class="form-input" maxlength="2" />
              </div>
            </div>

            <div class="form-grid-two">
              <div class="form-group">
                <label class="form-label required">Sección</label>
                <input type="number" v-model.number="destino.seccion" class="form-input" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Sección Alfa</label>
                <input v-model="destino.seccion_alfa" class="form-input" maxlength="2" />
              </div>
            </div>

            <div class="form-grid-two">
              <div class="form-group">
                <label class="form-label required">Línea</label>
                <input type="number" v-model.number="destino.linea" class="form-input" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Línea Alfa</label>
                <input v-model="destino.linea_alfa" class="form-input" maxlength="2" />
              </div>
            </div>

            <div class="form-grid-two">
              <div class="form-group">
                <label class="form-label required">Fosa</label>
                <input type="number" v-model.number="destino.fosa" class="form-input" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Fosa Alfa</label>
                <input v-model="destino.fosa_alfa" class="form-input" maxlength="4" />
              </div>
            </div>
          </div>
        </div>

        <div class="form-actions mt-3">
          <button class="btn-municipal-primary" @click="verificarUbicaciones" :disabled="!ubicacionesValidas">
            <font-awesome-icon icon="search" />
            Verificar Ubicaciones
          </button>
        </div>
      </div>
    </div>

    <!-- Pagos Encontrados -->
    <div v-if="pagosOrigen.length > 0" class="municipal-card mt-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="list" />
        Pagos en Ubicación Origen ({{ pagosOrigen.length }})
      </div>
      <div class="municipal-card-body">
        <div v-if="folioDestino" class="alert-info mb-3">
          <font-awesome-icon icon="info-circle" />
          <span>
            Destino: Folio {{ folioDestino.control_rcm }} - {{ folioDestino.nombre }}
          </span>
        </div>

        <div class="table-container">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Control ID</th>
                <th>Folio</th>
                <th>Fecha</th>
                <th>Años</th>
                <th>Importe</th>
                <th>Recargos</th>
                <th>Total</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="pago in pagosOrigen" :key="pago.control_id">
                <td>{{ pago.control_id }}</td>
                <td>{{ pago.control_rcm }}</td>
                <td>{{ formatDate(pago.fecing) }}</td>
                <td>{{ pago.axo_pago_desde }}-{{ pago.axo_pago_hasta }}</td>
                <td>{{ formatCurrency(pago.importe_anual) }}</td>
                <td>{{ formatCurrency(pago.importe_recargos) }}</td>
                <td class="text-bold">
                  {{ formatCurrency(pago.importe_anual + pago.importe_recargos) }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div class="form-actions mt-3">
          <button class="btn-municipal-secondary" @click="cancelar">
            <font-awesome-icon icon="times" />
            Cancelar
          </button>
          <button class="btn-municipal-primary" @click="confirmarTraslado">
            <font-awesome-icon icon="exchange-alt" />
            Trasladar {{ pagosOrigen.length }} Pago(s)
          </button>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      v-if="mostrarAyuda"
      title="Ayuda - Traslados por Ubicación"
      @close="mostrarAyuda = false"
    >
      <div class="help-content">
        <section class="help-section">
          <h3><font-awesome-icon icon="info-circle" /> Descripción</h3>
          <p>
            Este módulo traslada TODOS los pagos de una ubicación física completa
            (cementerio-clase-sección-línea-fosa) a otra ubicación física.
          </p>
        </section>

        <section class="help-section">
          <h3><font-awesome-icon icon="exclamation-triangle" /> Diferencia con Traslado de Folios</h3>
          <ul>
            <li><strong>Traslado de Folios:</strong> Mueve pagos seleccionados entre folios</li>
            <li><strong>Traslado por Ubicación:</strong> Mueve TODOS los pagos de una ubicación física a otra</li>
          </ul>
        </section>

        <section class="help-section">
          <h3><font-awesome-icon icon="list-ol" /> Proceso</h3>
          <ol>
            <li>Complete la ubicación origen (cementerio, clase, sección, línea, fosa)</li>
            <li>Complete la ubicación destino</li>
            <li>Presione "Verificar Ubicaciones"</li>
            <li>El sistema mostrará todos los pagos en la ubicación origen</li>
            <li>Confirme el traslado</li>
          </ol>
        </section>
      </div>
    </DocumentationModal>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Traslados'"
      :moduleName="'cementerios'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Swal from 'sweetalert2'

const { callProcedure } = useApi()
const { showSuccess, showError } = useToast()

const mostrarAyuda = ref(false)
const cementerios = ref([])
const pagosOrigen = ref([])
const folioDestino = ref(null)

const origen = ref({
  cementerio: '',
  clase: null,
  clase_alfa: '',
  seccion: null,
  seccion_alfa: '',
  linea: null,
  linea_alfa: '',
  fosa: null,
  fosa_alfa: ''
})

const destino = ref({
  cementerio: '',
  clase: null,
  clase_alfa: '',
  seccion: null,
  seccion_alfa: '',
  linea: null,
  linea_alfa: '',
  fosa: null,
  fosa_alfa: ''
})

const ubicacionesValidas = computed(() => {
  return origen.value.cementerio && origen.value.clase && origen.value.seccion &&
         origen.value.linea && origen.value.fosa &&
         destino.value.cementerio && destino.value.clase && destino.value.seccion &&
         destino.value.linea && destino.value.fosa
})

onMounted(async () => {
  try {
    const result = await callProcedure('sp_cem_listar_cementerios', {})
    cementerios.value = result.data || []
  } catch (error) {
  }
})

const verificarUbicaciones = async () => {
  try {
    // Buscar pagos en ubicación origen
    const resultPagos = await callProcedure('sp_cem_buscar_pagos_por_ubicacion', {
      p_cementerio: origen.value.cementerio,
      p_clase: origen.value.clase,
      p_clase_alfa: origen.value.clase_alfa || null,
      p_seccion: origen.value.seccion,
      p_seccion_alfa: origen.value.seccion_alfa || null,
      p_linea: origen.value.linea,
      p_linea_alfa: origen.value.linea_alfa || null,
      p_fosa: origen.value.fosa,
      p_fosa_alfa: origen.value.fosa_alfa || null
    })

    pagosOrigen.value = resultPagos.data || []

    if (pagosOrigen.value.length === 0) {
      showError('No se encontraron pagos en la ubicación origen')
      return
    }

    // Buscar folio destino
    const resultFolio = await callProcedure('sp_cem_buscar_folio_por_ubicacion', {
      p_cementerio: destino.value.cementerio,
      p_clase: destino.value.clase,
      p_clase_alfa: destino.value.clase_alfa || null,
      p_seccion: destino.value.seccion,
      p_seccion_alfa: destino.value.seccion_alfa || null,
      p_linea: destino.value.linea,
      p_linea_alfa: destino.value.linea_alfa || null,
      p_fosa: destino.value.fosa,
      p_fosa_alfa: destino.value.fosa_alfa || null
    })

    if (resultFolio.resultado !== 'S') {
      showError('No se encontró folio en la ubicación destino')
      return
    }

    folioDestino.value = {
      control_rcm: resultFolio.control_rcm,
      nombre: resultFolio.nombre
    }

  } catch (error) {
    showError('Error al verificar las ubicaciones')
  }
}

const confirmarTraslado = async () => {
  const result = await Swal.fire({
    title: '¿Confirmar traslado?',
    html: `Se trasladarán <strong>${pagosOrigen.value.length}</strong> pago(s)<br>al folio <strong>${folioDestino.value.control_rcm}</strong>`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, trasladar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  try {
    const resultTraslado = await callProcedure('sp_cem_trasladar_pagos_ubicacion', {
      p_cem_origen: origen.value.cementerio,
      p_clase_origen: origen.value.clase,
      p_clase_alfa_origen: origen.value.clase_alfa || null,
      p_sec_origen: origen.value.seccion,
      p_sec_alfa_origen: origen.value.seccion_alfa || null,
      p_lin_origen: origen.value.linea,
      p_lin_alfa_origen: origen.value.linea_alfa || null,
      p_fosa_origen: origen.value.fosa,
      p_fosa_alfa_origen: origen.value.fosa_alfa || null,
      p_cem_destino: destino.value.cementerio,
      p_clase_destino: destino.value.clase,
      p_clase_alfa_destino: destino.value.clase_alfa || null,
      p_sec_destino: destino.value.seccion,
      p_sec_alfa_destino: destino.value.seccion_alfa || null,
      p_lin_destino: destino.value.linea,
      p_lin_alfa_destino: destino.value.linea_alfa || null,
      p_fosa_destino: destino.value.fosa,
      p_fosa_alfa_destino: destino.value.fosa_alfa || null,
      p_control_rcm_destino: folioDestino.value.control_rcm,
      p_usuario: 1
    })

    if (resultTraslado.resultado === 'S') {
      showSuccess('Pagos trasladados exitosamente')
      cancelar()
    } else {
      showError(resultTraslado.mensaje || 'Error al trasladar')
    }
  } catch (error) {
    showError('Error al realizar el traslado')
  }
}

const cancelar = () => {
  origen.value = { cementerio: '', clase: null, clase_alfa: '', seccion: null, seccion_alfa: '', linea: null, linea_alfa: '', fosa: null, fosa_alfa: '' }
  destino.value = { cementerio: '', clase: null, clase_alfa: '', seccion: null, seccion_alfa: '', linea: null, linea_alfa: '', fosa: null, fosa_alfa: '' }
  pagosOrigen.value = []
  folioDestino.value = null
}

const formatCurrency = (value) => {
  if (value == null) return '$0.00'
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value)
}

const formatDate = (date) => {
  if (!date) return ''
  return new Date(date).toLocaleDateString('es-MX')
}

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>

<style scoped>
/* Layout único de traslado por ubicaciones - Justificado mantener scoped */
.ubicaciones-grid {
  display: grid;
  grid-template-columns: 1fr auto 1fr;
  gap: 2rem;
  align-items: start;
}

.ubicacion-form {
  background: var(--color-bg-secondary);
  border-radius: 8px;
  padding: 1.5rem;
}

.ubicacion-title {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1rem;
  font-size: 1.1rem;
  font-weight: 600;
}

.ubicacion-title.origin {
  color: var(--color-warning);
}

.ubicacion-title.destination {
  color: var(--color-success);
}

.transfer-arrow {
  font-size: 3rem;
  color: var(--color-primary);
  align-self: center;
}

@media (max-width: 768px) {
  .ubicaciones-grid {
    grid-template-columns: 1fr;
  }

  .transfer-arrow {
    transform: rotate(90deg);
    font-size: 2rem;
  }
}
</style>
