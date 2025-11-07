<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="times-circle" />
      </div>
      <div class="module-view-info">
        <h1>Cancelación de Trámites</h1>
        <p>Padrón de Licencias - Cancelar trámites en proceso</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Búsqueda de Trámite -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Buscar Trámite
          </h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="buscarTramite">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Número de Trámite:</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model="searchIdTramite"
                  placeholder="Ingrese número de trámite"
                  required
                  :disabled="loading"
                />
              </div>
            </div>
            <div class="button-group">
              <button
                type="submit"
                class="btn-municipal-primary"
                :disabled="loading || !searchIdTramite"
              >
                <font-awesome-icon icon="search" />
                Buscar
              </button>
              <button
                type="button"
                class="btn-municipal-secondary"
                @click="limpiar"
                :disabled="loading"
              >
                <font-awesome-icon icon="times" />
                Limpiar
              </button>
            </div>
          </form>
        </div>
      </div>

      <!-- Información del Trámite -->
      <div class="municipal-card" v-if="tramiteData">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="file-alt" />
            Información del Trámite #{{ tramiteData.id_tramite }}
          </h5>
          <div class="header-right">
            <span
              class="badge"
              :class="{
                'badge-success': tramiteData.estatus === 'A',
                'badge-danger': tramiteData.estatus === 'C',
                'badge-warning': tramiteData.estatus === 'T',
                'badge-secondary': tramiteData.estatus === 'R'
              }"
            >
              {{ getEstatusText(tramiteData.estatus) }}
            </span>
          </div>
        </div>

        <div class="municipal-card-body">
          <!-- Grid de detalles -->
          <div class="tramite-details-grid">
            <!-- Sección: Datos Generales -->
            <div class="tramite-detail-section">
              <h6 class="tramite-section-title">
                <font-awesome-icon icon="id-card" class="me-2" />
                Datos Generales
              </h6>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">ID Trámite:</span>
                <span class="tramite-detail-value"><strong>{{ tramiteData.id_tramite }}</strong></span>
              </div>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">Folio:</span>
                <span class="tramite-detail-value">{{ tramiteData.folio || 'N/A' }}</span>
              </div>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">Tipo:</span>
                <span class="tramite-detail-value">{{ tramiteData.tipo_tramite }}</span>
              </div>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">Recaudadora:</span>
                <span class="tramite-detail-value">{{ tramiteData.recaud }}</span>
              </div>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">Propietario:</span>
                <span class="tramite-detail-value">{{ propietarioCompleto }}</span>
              </div>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">RFC:</span>
                <span class="tramite-detail-value">{{ tramiteData.rfc || 'N/A' }}</span>
              </div>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">CURP:</span>
                <span class="tramite-detail-value">{{ tramiteData.curp || 'N/A' }}</span>
              </div>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">Fecha Captura:</span>
                <span class="tramite-detail-value">{{ formatDate(tramiteData.feccap) }}</span>
              </div>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">Capturista:</span>
                <span class="tramite-detail-value">{{ tramiteData.capturista }}</span>
              </div>
            </div>

            <!-- Sección: Giro y Actividad -->
            <div class="tramite-detail-section">
              <h6 class="tramite-section-title">
                <font-awesome-icon icon="briefcase" class="me-2" />
                Giro y Actividad
              </h6>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">Giro:</span>
                <span class="tramite-detail-value">{{ giroDescripcion }}</span>
              </div>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">Actividad:</span>
                <span class="tramite-detail-value">{{ tramiteData.actividad }}</span>
              </div>
            </div>

            <!-- Sección: Ubicación -->
            <div class="tramite-detail-section">
              <h6 class="tramite-section-title">
                <font-awesome-icon icon="map-marker-alt" class="me-2" />
                Ubicación
              </h6>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">Domicilio:</span>
                <span class="tramite-detail-value">{{ tramiteData.ubicacion }}</span>
              </div>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">No. Ext:</span>
                <span class="tramite-detail-value">{{ tramiteData.numext_ubic || 'S/N' }} {{ tramiteData.letraext_ubic }}</span>
              </div>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">No. Int:</span>
                <span class="tramite-detail-value">{{ tramiteData.numint_ubic || 'N/A' }} {{ tramiteData.letraint_ubic }}</span>
              </div>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">Colonia:</span>
                <span class="tramite-detail-value">{{ tramiteData.colonia_ubic }}</span>
              </div>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">Zona:</span>
                <span class="tramite-detail-value">{{ tramiteData.zona }} - {{ tramiteData.subzona }}</span>
              </div>
            </div>

            <!-- Sección: Datos Técnicos -->
            <div class="tramite-detail-section">
              <h6 class="tramite-section-title">
                <font-awesome-icon icon="ruler-combined" class="me-2" />
                Datos Técnicos
              </h6>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">Sup. Construida:</span>
                <span class="tramite-detail-value">{{ tramiteData.sup_construida }} m²</span>
              </div>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">Sup. Autorizada:</span>
                <span class="tramite-detail-value">{{ tramiteData.sup_autorizada }} m²</span>
              </div>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">Num. Cajones:</span>
                <span class="tramite-detail-value">{{ tramiteData.num_cajones }}</span>
              </div>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">Num. Empleados:</span>
                <span class="tramite-detail-value">{{ tramiteData.num_empleados }}</span>
              </div>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">Aforo:</span>
                <span class="tramite-detail-value">{{ tramiteData.aforo }}</span>
              </div>
            </div>

            <!-- Sección: Referencias (si existen) -->
            <div class="tramite-detail-section" v-if="tramiteData.licencia_ref || tramiteData.id_licencia || tramiteData.id_anuncio">
              <h6 class="tramite-section-title">
                <font-awesome-icon icon="link" class="me-2" />
                Referencias
              </h6>
              <div class="tramite-detail-row" v-if="tramiteData.licencia_ref">
                <span class="tramite-detail-label">Licencia Ref:</span>
                <span class="tramite-detail-value">{{ tramiteData.licencia_ref }}</span>
              </div>
              <div class="tramite-detail-row" v-if="tramiteData.id_licencia">
                <span class="tramite-detail-label">ID Licencia:</span>
                <span class="tramite-detail-value">{{ tramiteData.id_licencia }}</span>
              </div>
              <div class="tramite-detail-row" v-if="tramiteData.id_anuncio">
                <span class="tramite-detail-label">ID Anuncio:</span>
                <span class="tramite-detail-value">{{ tramiteData.id_anuncio }}</span>
              </div>
            </div>
          </div>

          <!-- Alertas de estado -->
          <div class="alert alert-danger mt-4" v-if="tramiteData.estatus === 'C'">
            <div class="d-flex align-items-center">
              <font-awesome-icon icon="exclamation-triangle" class="me-2" />
              <div>
                <strong>Trámite Cancelado</strong>
                <p class="mb-0">Este trámite ya se encuentra cancelado. No se puede cancelar nuevamente.</p>
              </div>
            </div>
          </div>

          <div class="alert alert-warning mt-4" v-if="tramiteData.estatus === 'A'">
            <div class="d-flex align-items-center">
              <font-awesome-icon icon="exclamation-triangle" class="me-2" />
              <div>
                <strong>Trámite Autorizado</strong>
                <p class="mb-0">Este trámite ya fue autorizado. Para dar de baja use el módulo de Baja de Licencias.</p>
              </div>
            </div>
          </div>

          <!-- Botones de acción -->
          <div class="button-group mt-4">
            <button
              class="btn-municipal-danger"
              :disabled="!puedeCancelar"
              @click="confirmarCancelacion"
            >
              <font-awesome-icon icon="times-circle" />
              Cancelar Trámite
            </button>
            <button
              class="btn-municipal-secondary"
              @click="limpiar"
            >
              <font-awesome-icon icon="times" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Empty state -->
      <div class="municipal-card" v-if="!tramiteData && !loading">
        <div class="municipal-card-body">
          <div class="empty-state-content">
            <div class="empty-state-icon">
              <font-awesome-icon icon="search" />
            </div>
            <p class="empty-state-text">No hay trámite seleccionado</p>
            <p class="empty-state-hint">Ingrese el número de trámite en el formulario de búsqueda</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <Modal :show="showDocumentation" @close="closeDocumentation">
      <template #header>
        <h5>
          <font-awesome-icon icon="question-circle" class="me-2" />
          Ayuda - Cancelación de Trámites
        </h5>
      </template>
      <template #body>
        <h6>Descripción del Módulo</h6>
        <p>Este módulo permite cancelar trámites que se encuentren en proceso o rechazados.</p>

        <h6 class="mt-3">Estados de Trámites</h6>
        <ul>
          <li><strong>T - En Trámite:</strong> Puede ser cancelado</li>
          <li><strong>R - Rechazado:</strong> Puede ser cancelado</li>
          <li><strong>A - Autorizado:</strong> NO puede ser cancelado (usar módulo de Baja de Licencias)</li>
          <li><strong>C - Cancelado:</strong> Ya está cancelado</li>
        </ul>

        <h6 class="mt-3">Procedimiento</h6>
        <ol>
          <li>Ingrese el número de trámite a cancelar</li>
          <li>Verifique la información del trámite</li>
          <li>Si el estado lo permite, haga clic en "Cancelar Trámite"</li>
          <li>Ingrese el motivo de la cancelación</li>
          <li>Confirme la operación</li>
        </ol>

        <div class="alert alert-info mt-3">
          <strong>
            <font-awesome-icon icon="info-circle" class="me-1" />
            Nota:
          </strong>
          La cancelación de un trámite es una operación irreversible. Asegúrese de ingresar el motivo correcto.
        </div>
      </template>
      <template #footer>
        <button class="btn-municipal-secondary" @click="closeDocumentation">
          Cerrar
        </button>
      </template>
    </Modal>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Modal from '@/components/common/Modal.vue'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { handleError, showToast } = useLicenciasErrorHandler()

// Estado
const searchIdTramite = ref('')
const tramiteData = ref(null)
const giroDescripcion = ref('')
const loading = ref(false)
const showDocumentation = ref(false)

// Computed
const propietarioCompleto = computed(() => {
  if (!tramiteData.value) return ''
  const parts = [
    tramiteData.value.primer_ap || '',
    tramiteData.value.segundo_ap || '',
    tramiteData.value.propietario || ''
  ]
  return parts.filter(p => p.trim()).join(' ')
})

const puedeCancelar = computed(() => {
  if (!tramiteData.value) return false
  const estatus = tramiteData.value.estatus
  // Solo puede cancelar si está en trámite (T) o rechazado (R)
  return estatus === 'T' || estatus === 'R'
})

// Métodos
const buscarTramite = async () => {
  if (!searchIdTramite.value) {
    showToast('warning', 'Debe ingresar el número de trámite')
    return
  }

  showLoading('Buscando trámite...')
  const startTime = performance.now()

  try {
    // 1. Buscar trámite
    const responseTramite = await execute(
      'SP_GET_TRAMITE_BY_ID',
      'padron_licencias',
      [{ nombre: 'p_id_tramite', valor: parseInt(searchIdTramite.value), tipo: 'integer' }],
      'comun'
    )

    if (!responseTramite || !responseTramite.result || responseTramite.result.length === 0) {
      showToast('error', 'Trámite no encontrado', 'No existe un trámite con ese número')
      tramiteData.value = null
      giroDescripcion.value = ''
      hideLoading()
      return
    }

    tramiteData.value = responseTramite.result[0]

    // 2. Buscar descripción del giro si existe id_giro
    if (tramiteData.value.id_giro) {
      try {
        const responseGiro = await execute(
          'SP_GET_GIRO_BY_ID',
          'padron_licencias',
          [{ nombre: 'p_id_giro', valor: parseInt(tramiteData.value.id_giro), tipo: 'integer' }],
          'comun'
        )

        if (responseGiro && responseGiro.result && responseGiro.result.length > 0) {
          giroDescripcion.value = responseGiro.result[0].descripcion
        } else {
          giroDescripcion.value = 'Giro no encontrado'
        }
      } catch (error) {
        console.error('Error al buscar giro:', error)
        giroDescripcion.value = 'Error al cargar giro'
      }
    } else {
      giroDescripcion.value = 'Sin giro'
    }

    const endTime = performance.now()
    const duration = endTime - startTime
    const durationText = duration < 1000 ? `${Math.round(duration)}ms` : `${(duration / 1000).toFixed(2)}s`

    showToast('success', 'Trámite encontrado', durationText)
  } catch (error) {
    console.error('Error al buscar trámite:', error)
    handleError(error)
    tramiteData.value = null
    giroDescripcion.value = ''
  } finally {
    hideLoading()
  }
}

const confirmarCancelacion = async () => {
  // 1. Solicitar motivo de cancelación
  const { value: motivo } = await Swal.fire({
    title: 'Motivo de Cancelación',
    html: `
      <p>Ingrese el motivo por el cual se cancela el trámite <strong>#${tramiteData.value.id_tramite}</strong>:</p>
      <textarea id="swal-motivo" class="swal2-textarea" placeholder="Motivo de la cancelación..." rows="4" style="width: 100%;"></textarea>
    `,
    focusConfirm: false,
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Continuar',
    cancelButtonText: 'Cancelar',
    preConfirm: () => {
      const motivoValue = document.getElementById('swal-motivo').value
      if (!motivoValue || !motivoValue.trim()) {
        Swal.showValidationMessage('Debe ingresar el motivo de la cancelación')
      }
      return motivoValue
    }
  })

  if (!motivo) return

  // 2. Confirmación final
  const confirmacion = await Swal.fire({
    icon: 'warning',
    title: '¿Cancelar trámite?',
    html: `
      <p>¿Está seguro de cancelar el trámite <strong>#${tramiteData.value.id_tramite}</strong>?</p>
      <div class="alert alert-danger mt-3 text-start">
        <strong>Motivo:</strong> ${motivo}
      </div>
      <p class="text-danger mt-3"><strong>⚠️ Esta acción NO se puede deshacer</strong></p>
    `,
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, cancelar trámite',
    cancelButtonText: 'No, volver'
  })

  if (!confirmacion.isConfirmed) return

  // 3. Ejecutar cancelación
  showLoading('Cancelando trámite...')
  const startTime = performance.now()

  try {
    const response = await execute(
      'SP_CANCEL_TRAMITE',
      'padron_licencias',
      [
        { nombre: 'p_id_tramite', valor: parseInt(tramiteData.value.id_tramite), tipo: 'integer' },
        { nombre: 'p_motivo', valor: motivo, tipo: 'string' }
      ],
      'comun'
    )

    if (response && response.result && response.result.length > 0) {
      const resultado = response.result[0]

      const endTime = performance.now()
      const duration = endTime - startTime
      const durationText = duration < 1000 ? `${Math.round(duration)}ms` : `${(duration / 1000).toFixed(2)}s`

      if (resultado.new_status === 'C') {
        // Actualizar estado local
        tramiteData.value.estatus = 'C'

        await Swal.fire({
          icon: 'success',
          title: 'Trámite Cancelado',
          text: resultado.result,
          confirmButtonColor: '#ea8215',
          timer: 3000
        })

        showToast('success', 'Trámite cancelado exitosamente', durationText)
      } else {
        showToast('error', resultado.result || 'No se pudo cancelar el trámite')
      }
    } else {
      showToast('error', 'No se pudo cancelar el trámite', 'Respuesta inválida del servidor')
    }
  } catch (error) {
    console.error('Error al cancelar trámite:', error)
    handleError(error)
  } finally {
    hideLoading()
  }
}

const limpiar = () => {
  searchIdTramite.value = ''
  tramiteData.value = null
  giroDescripcion.value = ''
}

const getEstatusText = (estatus) => {
  const estados = {
    'A': 'Autorizado',
    'C': 'Cancelado',
    'T': 'En Trámite',
    'R': 'Rechazado'
  }
  return estados[estatus] || estatus
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-MX', { year: 'numeric', month: '2-digit', day: '2-digit' })
  } catch (e) {
    return dateString
  }
}

const openDocumentation = () => {
  showDocumentation.value = true
}

const closeDocumentation = () => {
  showDocumentation.value = false
}
</script>

<!-- NO inline styles - All styles in municipal-theme.css -->
