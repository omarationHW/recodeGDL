<template>
  <div class="module-view">
    <!-- Header -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="ban" />
      </div>
      <div class="module-view-info">
        <h1>Baja de Anuncios</h1>
        <p>Padrón de Licencias - Dar de baja anuncios publicitarios</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-secondary"
          @click="regresarConsulta"
        >
          <font-awesome-icon icon="arrow-left" />
          Regresar a Consulta
        </button>
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
      <!-- Panel de Búsqueda (Colapsable) -->
      <div class="municipal-card">
        <div
          class="municipal-card-header accordion-header"
          @click="showBusqueda = !showBusqueda"
          style="cursor: pointer;"
        >
          <h5 class="municipal-card-title">
            <font-awesome-icon icon="search" />
            Buscar Anuncio
          </h5>
          <font-awesome-icon
            :icon="showBusqueda ? 'chevron-up' : 'chevron-down'"
            class="accordion-icon"
          />
        </div>
        <div class="municipal-card-body" v-show="showBusqueda">
          <form @submit.prevent="buscarAnuncio">
            <div class="form-row">
              <div class="form-group col-md-6">
                <label class="municipal-form-label">
                  <font-awesome-icon icon="bullhorn" class="me-1" />
                  Número de Anuncio *
                </label>
                <div class="input-group">
                  <input
                    type="number"
                    class="municipal-form-control"
                    v-model.number="searchAnuncio"
                    placeholder="Ingrese número de anuncio"
                    required
                    min="1"
                  />
                  <button
                    type="submit"
                    class="btn-municipal-primary"
                    :disabled="!searchAnuncio"
                  >
                    <font-awesome-icon icon="search" /> Buscar
                  </button>
                </div>
              </div>
            </div>
          </form>
        </div>
      </div>

      <!-- Información del Anuncio -->
      <div class="municipal-card" v-if="anuncioData">
        <div class="municipal-card-header">
          <h5 class="municipal-card-title">
            <font-awesome-icon icon="bullhorn" />
            Anuncio #{{ anuncioData.anuncio }}
            <span
              :class="anuncioData.vigente === 'V' ? 'badge-success' : 'badge-danger'"
              class="badge ms-2"
            >
              {{ anuncioData.vigente === 'V' ? 'VIGENTE' : 'NO VIGENTE' }}
            </span>
          </h5>
        </div>
        <div class="municipal-card-body">
          <!-- Datos del Anuncio -->
          <div class="details-grid">
            <!-- Licencia Ligada -->
            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="link" />
                Licencia Ligada
              </h6>
              <table class="detail-table">
                <tr>
                  <td class="label">Licencia:</td>
                  <td>
                    <strong>#{{ anuncioData.licencia }}</strong>
                  </td>
                </tr>
                <tr>
                  <td class="label">Propietario:</td>
                  <td>{{ anuncioData.propietario_licencia || 'N/A' }}</td>
                </tr>
              </table>
            </div>

            <!-- Información del Anuncio -->
            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="info-circle" />
                Información del Anuncio
              </h6>
              <table class="detail-table">
                <tr>
                  <td class="label">Texto:</td>
                  <td>{{ anuncioData.texto_anuncio || 'N/A' }}</td>
                </tr>
                <tr>
                  <td class="label">Giro:</td>
                  <td>{{ anuncioData.descripcion_giro || 'N/A' }}</td>
                </tr>
              </table>
            </div>

            <!-- Dimensiones -->
            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="ruler-combined" />
                Dimensiones
              </h6>
              <table class="detail-table">
                <tr>
                  <td class="label">Medidas:</td>
                  <td>
                    {{ anuncioData.medidas1 || '0' }} x {{ anuncioData.medidas2 || '0' }} m
                    <span class="text-muted" v-if="anuncioData.medidas1 && anuncioData.medidas2">
                      ({{ (anuncioData.medidas1 * anuncioData.medidas2).toFixed(2) }} m²)
                    </span>
                  </td>
                </tr>
                <tr>
                  <td class="label">Caras:</td>
                  <td>{{ anuncioData.num_caras || '0' }}</td>
                </tr>
                <tr>
                  <td class="label">Misma Forma:</td>
                  <td>{{ anuncioData.misma_forma || 'N/A' }}</td>
                </tr>
              </table>
            </div>

            <!-- Ubicación -->
            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="map-marker-alt" />
                Ubicación
              </h6>
              <table class="detail-table">
                <tr>
                  <td class="label">Domicilio:</td>
                  <td>
                    {{ anuncioData.ubicacion || 'N/A' }}
                    {{ anuncioData.numext_ubic ? '#' + anuncioData.numext_ubic : '' }}
                    {{ anuncioData.numint_ubic ? 'Int. ' + anuncioData.numint_ubic : '' }}
                  </td>
                </tr>
                <tr>
                  <td class="label">Colonia:</td>
                  <td>{{ anuncioData.colonia_ubic || 'N/A' }}</td>
                </tr>
                <tr>
                  <td class="label">Fecha Otorgamiento:</td>
                  <td>{{ formatDate(anuncioData.fecha_otorgamiento) }}</td>
                </tr>
                <tr v-if="anuncioData.bloqueado > 0">
                  <td colspan="2">
                    <div class="alert alert-warning mb-0">
                      <font-awesome-icon icon="lock" />
                      <strong>Anuncio Bloqueado</strong>
                    </div>
                  </td>
                </tr>
              </table>
            </div>
          </div>

          <!-- Formulario de Baja -->
          <div class="mt-4" v-if="anuncioData.vigente === 'V'">
            <h6 class="section-title text-danger">
              <font-awesome-icon icon="exclamation-triangle" />
              Registrar Baja de Anuncio
            </h6>

            <form @submit.prevent="confirmarBaja">
              <div class="form-row">
                <div class="form-group col-md-12">
                  <label class="municipal-form-label">
                    <font-awesome-icon icon="comment-alt" class="me-1" />
                    Motivo de la Baja *
                  </label>
                  <textarea
                    class="municipal-form-control"
                    v-model="bajaForm.motivo"
                    rows="3"
                    placeholder="Ingrese el motivo detallado de la baja"
                    required
                    maxlength="500"
                  ></textarea>
                  <small class="form-text text-muted">
                    {{ bajaForm.motivo.length }}/500 caracteres
                  </small>
                </div>
              </div>

              <div class="form-row">
                <div class="form-group col-md-12">
                  <div class="custom-control custom-checkbox">
                    <input
                      type="checkbox"
                      class="custom-control-input"
                      id="bajaError"
                      v-model="bajaForm.bajaError"
                    />
                    <label class="custom-control-label" for="bajaError">
                      <strong>Baja por error</strong> (no requiere año/folio)
                    </label>
                  </div>
                </div>
              </div>

              <div class="form-row" v-if="!bajaForm.bajaError">
                <div class="form-group col-md-6">
                  <label class="municipal-form-label">
                    <font-awesome-icon icon="calendar" class="me-1" />
                    Año *
                  </label>
                  <input
                    type="number"
                    class="municipal-form-control"
                    v-model.number="bajaForm.anio"
                    placeholder="2025"
                    min="2000"
                    max="2030"
                    :required="!bajaForm.bajaError"
                  />
                </div>
                <div class="form-group col-md-6">
                  <label class="municipal-form-label">
                    <font-awesome-icon icon="hashtag" class="me-1" />
                    Folio *
                  </label>
                  <input
                    type="number"
                    class="municipal-form-control"
                    v-model.number="bajaForm.folio"
                    placeholder="1234"
                    min="1"
                    :required="!bajaForm.bajaError"
                  />
                </div>
              </div>

              <div class="alert alert-danger mt-3">
                <font-awesome-icon icon="exclamation-circle" />
                <strong>ADVERTENCIA:</strong> Esta acción NO se puede deshacer.
                El anuncio será dado de baja permanentemente.
              </div>

              <div class="form-row">
                <div class="form-group col-md-12">
                  <button
                    type="submit"
                    class="btn-municipal-danger"
                  >
                    <font-awesome-icon icon="ban" /> Dar de Baja Anuncio
                  </button>
                  <button
                    type="button"
                    class="btn-municipal-secondary ms-2"
                    @click="cancelar"
                  >
                    <font-awesome-icon icon="times" /> Cancelar
                  </button>
                </div>
              </div>
            </form>
          </div>

          <!-- Anuncio ya dado de baja -->
          <div class="alert alert-warning mt-3" v-else>
            <font-awesome-icon icon="info-circle" />
            <strong>Este anuncio ya está dado de baja</strong>
            <p class="mb-0 mt-2">
              <strong>Fecha de baja:</strong> {{ formatDate(anuncioData.fecha_baja) }}<br>
              <strong>Año:</strong> {{ anuncioData.axo_baja || 'N/A' }}<br>
              <strong>Folio:</strong> {{ anuncioData.folio_baja || 'N/A' }}<br>
              <strong>Motivo:</strong> {{ anuncioData.espubic || 'N/A' }}
            </p>
          </div>
        </div>
      </div>

      <!-- Mensaje cuando no hay anuncio buscado -->
      <div class="municipal-card text-center" v-if="!anuncioData && !primeraBusqueda">
        <div class="municipal-card-body py-5">
          <font-awesome-icon icon="search" size="3x" class="text-muted mb-3" />
          <h5 class="text-muted">Busque un anuncio para dar de baja</h5>
          <p class="text-muted">Ingrese el número de anuncio en el panel de búsqueda.</p>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'bajaAnunciofrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useToast } from '@/composables/useToast'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Swal from 'sweetalert2'

const router = useRouter()
const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { handleApiError } = useLicenciasErrorHandler()
const { showToast } = useToast()

// Estado
const showDocumentation = ref(false)
const showBusqueda = ref(true)
const primeraBusqueda = ref(false)
const searchAnuncio = ref(null)
const anuncioData = ref(null)

const bajaForm = ref({
  motivo: '',
  anio: new Date().getFullYear(),
  folio: null,
  bajaError: false
})

// Métodos
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const regresarConsulta = () => {
  router.push('/padron-licencias/consulta-anuncios')
}

const buscarAnuncio = async () => {
  if (!searchAnuncio.value) {
    showToast('warning', 'Ingrese el número de anuncio')
    return
  }

  showLoading('Buscando anuncio...', 'Consultando base de datos')
  primeraBusqueda.value = true
  showBusqueda.value = false

  try {
    const response = await execute(
      'sp_bajaanun_buscar_anuncio',
      'padron_licencias',
      [{ nombre: 'p_anuncio', valor: searchAnuncio.value, tipo: 'integer' }],
      'guadalajara',
      null,
      'comun' // esquema
    )

    if (response && response.result && response.result.length > 0) {
      anuncioData.value = response.result[0]
      showToast('success', 'Anuncio encontrado')
    } else {
      anuncioData.value = null
      showToast('warning', 'No se encontró el anuncio')
    }
  } catch (error) {
    console.error('Error al buscar anuncio:', error)
    handleApiError(error)
    anuncioData.value = null
  } finally {
    hideLoading()
  }
}

const confirmarBaja = async () => {
  // Validaciones
  if (!bajaForm.value.motivo.trim()) {
    showToast('warning', 'Debe ingresar el motivo de la baja')
    return
  }

  if (!bajaForm.value.bajaError && (!bajaForm.value.anio || !bajaForm.value.folio)) {
    showToast('warning', 'Debe ingresar año y folio para baja normal')
    return
  }

  // Validar que el anuncio no esté bloqueado
  if (anuncioData.value.bloqueado > 0) {
    await Swal.fire({
      icon: 'error',
      title: 'Anuncio Bloqueado',
      text: 'No se puede dar de baja el anuncio porque está bloqueado.',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  // Confirmación
  const result = await Swal.fire({
    icon: 'warning',
    title: '¿Dar de baja anuncio?',
    html: `
      <p>¿Está seguro de dar de baja el anuncio <strong>#${anuncioData.value.anuncio}</strong>?</p>
      <p><strong>Texto:</strong> ${anuncioData.value.texto_anuncio || 'N/A'}</p>
      <p><strong>Motivo:</strong> ${bajaForm.value.motivo}</p>
      <p class="text-danger mt-3"><strong>Esta acción NO se puede deshacer</strong></p>
    `,
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, dar de baja',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  // Solicitar firma
  const firmaResult = await solicitarFirma()
  if (!firmaResult.success) return

  // Ejecutar baja
  await ejecutarBaja()
}

const solicitarFirma = async () => {
  const { value: firma } = await Swal.fire({
    title: 'Firma de Autorización',
    input: 'password',
    inputLabel: 'Ingrese su firma para confirmar la baja:',
    inputPlaceholder: 'Firma',
    showCancelButton: true,
    confirmButtonText: 'Aceptar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#ea8215',
    inputValidator: (value) => {
      if (!value) {
        return 'Debe ingresar su firma'
      }
    }
  })

  if (!firma) {
    return { success: false }
  }

  // Verificar firma
  try {
    const response = await execute(
      'SP_VERIFICA_FIRMA',
      'padron_licencias',
      [
        { nombre: 'p_usuario', valor: localStorage.getItem('usuario') || '', tipo: 'string' },
        { nombre: 'p_login', valor: '', tipo: 'string' },
        { nombre: 'p_firma', valor: firma, tipo: 'string' },
        { nombre: 'p_modulos_id', valor: 1, tipo: 'integer' }
      ],
      'guadalajara',
      null,
      'comun'
    )

    if (response && response.result && response.result[0]?.firma_valida) {
      return { success: true }
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Firma Incorrecta',
        text: 'La firma ingresada no es válida',
        confirmButtonColor: '#ea8215'
      })
      return { success: false }
    }
  } catch (error) {
    console.error('Error verificando firma:', error)
    handleApiError(error)
    return { success: false }
  }
}

const ejecutarBaja = async () => {
  showLoading('Procesando baja de anuncio...', 'Esto puede tardar unos momentos')

  try {
    const response = await execute(
      'sp_bajaanun_ejecutar',
      'padron_licencias',
      [
        { nombre: 'p_anuncio', valor: searchAnuncio.value, tipo: 'integer' },
        { nombre: 'p_motivo', valor: bajaForm.value.motivo, tipo: 'string' },
        { nombre: 'p_anio', valor: bajaForm.value.bajaError ? null : bajaForm.value.anio, tipo: 'integer' },
        { nombre: 'p_folio', valor: bajaForm.value.bajaError ? null : bajaForm.value.folio, tipo: 'integer' },
        { nombre: 'p_baja_error', valor: bajaForm.value.bajaError, tipo: 'boolean' },
        { nombre: 'p_usuario', valor: localStorage.getItem('usuario') || 'sistema', tipo: 'string' }
      ],
      'guadalajara',
      null,
      'comun' // esquema
    )

    hideLoading()

    if (response && response.result && response.result.length > 0) {
      const resultado = response.result[0]

      if (resultado.success) {
        await Swal.fire({
          icon: 'success',
          title: 'Baja Registrada',
          text: resultado.message,
          confirmButtonColor: '#ea8215'
        })

        // Limpiar y buscar de nuevo para mostrar el estado actualizado
        await buscarAnuncio()
      } else {
        await Swal.fire({
          icon: 'error',
          title: 'Error',
          text: resultado.message,
          confirmButtonColor: '#ea8215'
        })
      }
    }
  } catch (error) {
    hideLoading()
    console.error('Error al dar de baja:', error)
    handleApiError(error)
  }
}

const cancelar = () => {
  searchAnuncio.value = null
  anuncioData.value = null
  primeraBusqueda.value = false
  showBusqueda.value = true
  bajaForm.value = {
    motivo: '',
    anio: new Date().getFullYear(),
    folio: null,
    bajaError: false
  }
}

const formatDate = (date) => {
  if (!date) return 'N/A'
  const d = new Date(date)
  return d.toLocaleDateString('es-MX', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

// Restaurar estado si viene de otra vista
onMounted(() => {
  const savedSearch = localStorage.getItem('bajaanuncio_search')
  if (savedSearch) {
    searchAnuncio.value = parseInt(savedSearch)
    localStorage.removeItem('bajaanuncio_search')
    buscarAnuncio()
  }
})
</script>

<style scoped>
.accordion-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  transition: background-color 0.2s;
}

.accordion-header:hover {
  background-color: #f3f4f6;
}

.accordion-icon {
  color: #9363CD;
  transition: transform 0.2s;
}

.details-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
  margin-bottom: 1.5rem;
}

.detail-section {
  background: #f9fafb;
  padding: 1rem;
  border-radius: 8px;
  border: 1px solid #e5e7eb;
}

.section-title {
  font-size: 0.9rem;
  color: #9363CD;
  font-weight: 600;
  margin-bottom: 0.75rem;
  padding-bottom: 0.5rem;
  border-bottom: 2px solid #9363CD;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.section-title.text-danger {
  color: #dc3545;
  border-bottom-color: #dc3545;
}

.detail-table {
  width: 100%;
  font-size: 0.875rem;
}

.detail-table tr {
  border-bottom: 1px solid #e5e7eb;
}

.detail-table tr:last-child {
  border-bottom: none;
}

.detail-table td {
  padding: 0.5rem 0;
}

.detail-table td.label {
  font-weight: 500;
  color: #6b7280;
  width: 40%;
}

.badge {
  display: inline-block;
  padding: 0.25rem 0.75rem;
  font-size: 0.75rem;
  font-weight: 600;
  border-radius: 12px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.badge-success {
  background-color: #10b981;
  color: white;
}

.badge-danger {
  background-color: #ef4444;
  color: white;
}

.alert {
  padding: 1rem;
  border-radius: 8px;
  margin-bottom: 1rem;
  display: flex;
  align-items: flex-start;
  gap: 0.75rem;
}

.alert svg {
  flex-shrink: 0;
  margin-top: 0.125rem;
}

.alert-warning {
  background-color: #fef3c7;
  border: 1px solid #f59e0b;
  color: #92400e;
}

.alert-danger {
  background-color: #fee2e2;
  border: 1px solid #ef4444;
  color: #991b1b;
}

.input-group {
  display: flex;
  gap: 0.5rem;
}

.input-group input {
  flex: 1;
}

@media (max-width: 768px) {
  .details-grid {
    grid-template-columns: 1fr;
  }

  .form-row {
    flex-direction: column;
  }

  .form-group.col-md-6,
  .form-group.col-md-12 {
    width: 100%;
  }
}
</style>
