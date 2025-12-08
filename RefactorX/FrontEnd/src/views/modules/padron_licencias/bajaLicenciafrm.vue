<template>
  <div class="module-view">
    <!-- Header -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="ban" />
      </div>
      <div class="module-view-info">
        <h1>Baja de Licencias</h1>
        <p>Padrón de Licencias - Dar de baja licencias comerciales</p>
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
          class="municipal-card-header accordion-header clickable-header"
          @click="showBusqueda = !showBusqueda"
        >
          <h5 class="municipal-card-title">
            <font-awesome-icon icon="search" />
            Buscar Licencia
          </h5>
          <font-awesome-icon
            :icon="showBusqueda ? 'chevron-up' : 'chevron-down'"
            class="accordion-icon"
          />
        </div>
        <div class="municipal-card-body" v-show="showBusqueda">
          <form @submit.prevent="buscarLicencia">
            <div class="form-row">
              <div class="form-group col-md-6">
                <label class="municipal-form-label">
                  <font-awesome-icon icon="id-card" class="me-1" />
                  Número de Licencia *
                </label>
                <div class="input-group">
                  <input
                    type="number"
                    class="municipal-form-control"
                    v-model.number="searchLicencia"
                    placeholder="Ingrese número de licencia"
                    required
                    min="1"
                  />
                  <button
                    type="submit"
                    class="btn-municipal-primary"
                    :disabled="!searchLicencia"
                  >
                    <font-awesome-icon icon="search" /> Buscar
                  </button>
                </div>
              </div>
            </div>
          </form>
        </div>
      </div>

      <!-- Información de la Licencia -->
      <div class="municipal-card" v-if="licenciaData">
        <div class="municipal-card-header">
          <h5 class="municipal-card-title">
            <font-awesome-icon icon="file-contract" />
            Licencia #{{ licenciaData.licencia }}
            <span
              :class="licenciaData.vigente === 'V' ? 'badge-success' : 'badge-danger'"
              class="badge ms-2"
            >
              {{ licenciaData.vigente === 'V' ? 'VIGENTE' : 'NO VIGENTE' }}
            </span>
          </h5>
        </div>
        <div class="municipal-card-body">
          <!-- Datos de la Licencia -->
          <div class="details-grid">
            <!-- Propietario -->
            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="user" />
                Propietario
              </h6>
              <table class="detail-table">
                <tr>
                  <td class="label">Nombre:</td>
                  <td>
                    <strong>{{ licenciaData.propietario }} {{ licenciaData.primer_ap }} {{ licenciaData.segundo_ap }}</strong>
                  </td>
                </tr>
                <tr>
                  <td class="label">RFC:</td>
                  <td>{{ licenciaData.rfc || 'N/A' }}</td>
                </tr>
              </table>
            </div>

            <!-- Actividad -->
            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="briefcase" />
                Actividad
              </h6>
              <table class="detail-table">
                <tr>
                  <td class="label">Giro:</td>
                  <td>{{ licenciaData.descripcion_giro || 'N/A' }}</td>
                </tr>
                <tr>
                  <td class="label">Actividad:</td>
                  <td>{{ licenciaData.actividad || 'N/A' }}</td>
                </tr>
              </table>
            </div>

            <!-- Ubicación -->
            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="map-marker-alt" />
                Ubicación del Negocio
              </h6>
              <table class="detail-table">
                <tr>
                  <td class="label">Domicilio:</td>
                  <td>
                    {{ licenciaData.ubicacion || 'N/A' }}
                    {{ licenciaData.numext_ubic ? '#' + licenciaData.numext_ubic : '' }}
                    {{ licenciaData.numint_ubic ? 'Int. ' + licenciaData.numint_ubic : '' }}
                  </td>
                </tr>
                <tr>
                  <td class="label">Colonia:</td>
                  <td>{{ licenciaData.colonia_ubic || 'N/A' }}</td>
                </tr>
              </table>
            </div>

            <!-- Información General -->
            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="info-circle" />
                Información General
              </h6>
              <table class="detail-table">
                <tr>
                  <td class="label">Fecha Otorgamiento:</td>
                  <td>{{ formatDate(licenciaData.fecha_otorgamiento) }}</td>
                </tr>
                <tr>
                  <td class="label">Sup. Construida:</td>
                  <td>{{ licenciaData.sup_construida ? licenciaData.sup_construida + ' m²' : 'N/A' }}</td>
                </tr>
                <tr>
                  <td class="label">Empleados:</td>
                  <td>{{ licenciaData.num_empleados || '0' }}</td>
                </tr>
                <tr v-if="licenciaData.bloqueado > 0">
                  <td colspan="2">
                    <div class="alert alert-warning mb-0">
                      <font-awesome-icon icon="lock" />
                      <strong>Licencia Bloqueada</strong>
                    </div>
                  </td>
                </tr>
              </table>
            </div>
          </div>

          <!-- Anuncios Ligados -->
          <div v-if="anuncios.length > 0" class="mt-3">
            <div class="alert alert-info">
              <font-awesome-icon icon="bullhorn" />
              <strong>Anuncios Ligados:</strong> Esta licencia tiene {{ anuncios.length }} anuncio(s) ligado(s).
              Al dar de baja la licencia, también se darán de baja todos los anuncios vigentes.
            </div>

            <div class="table-responsive">
              <table class="municipal-table">
                <thead>
                  <tr>
                    <th>Anuncio</th>
                    <th>Estado</th>
                    <th>Texto</th>
                    <th>Ubicación</th>
                    <th>Fecha Otorgamiento</th>
                    <th>Bloqueado</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="anuncio in anuncios" :key="anuncio.id_anuncio">
                    <td><strong>#{{ anuncio.anuncio }}</strong></td>
                    <td>
                      <span
                        :class="anuncio.vigente === 'V' ? 'badge-success' : 'badge-secondary'"
                        class="badge"
                      >
                        {{ anuncio.vigente === 'V' ? 'Vigente' : 'No Vigente' }}
                      </span>
                    </td>
                    <td>{{ anuncio.texto_anuncio || 'N/A' }}</td>
                    <td>{{ anuncio.ubicacion || 'N/A' }}</td>
                    <td>{{ formatDate(anuncio.fecha_otorgamiento) }}</td>
                    <td>
                      <span v-if="anuncio.bloqueado > 0" class="badge-danger badge">
                        <font-awesome-icon icon="lock" /> SÍ
                      </span>
                      <span v-else class="badge-success badge">NO</span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- Adeudos Pendientes -->
          <div v-if="adeudos.length > 0" class="mt-3">
            <div class="alert alert-danger">
              <font-awesome-icon icon="exclamation-triangle" />
              <strong>Adeudos Pendientes:</strong> Esta licencia tiene {{ adeudos.length }} adeudo(s) por un total de
              <strong>{{ new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(totalAdeudos) }}</strong>
            </div>

            <div class="table-responsive">
              <table class="municipal-table">
                <thead>
                  <tr>
                    <th>Concepto</th>
                    <th>Período</th>
                    <th class="text-end">Importe</th>
                    <th class="text-end">Recargos</th>
                    <th class="text-end">Total</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="adeudo in adeudos" :key="adeudo.id_adeudo || adeudo.id">
                    <td>{{ adeudo.concepto || adeudo.descripcion || 'N/A' }}</td>
                    <td>{{ adeudo.periodo || adeudo.anio || 'N/A' }}</td>
                    <td class="text-end">{{ new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(parseFloat(adeudo.importe) || 0) }}</td>
                    <td class="text-end">{{ new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(parseFloat(adeudo.recargos) || 0) }}</td>
                    <td class="text-end"><strong>{{ new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(parseFloat(adeudo.total) || parseFloat(adeudo.importe) || 0) }}</strong></td>
                  </tr>
                </tbody>
                <tfoot>
                  <tr class="table-warning">
                    <td colspan="4" class="text-end"><strong>TOTAL ADEUDOS:</strong></td>
                    <td class="text-end"><strong>{{ new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(totalAdeudos) }}</strong></td>
                  </tr>
                </tfoot>
              </table>
            </div>
          </div>

          <!-- Formulario de Baja -->
          <div class="mt-4" v-if="licenciaData.vigente === 'V'">
            <h6 class="section-title text-danger">
              <font-awesome-icon icon="exclamation-triangle" />
              Registrar Baja de Licencia
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
                La licencia y todos sus anuncios vigentes serán dados de baja permanentemente.
              </div>

              <div class="form-row">
                <div class="form-group col-md-12">
                  <button
                    type="submit"
                    class="btn-municipal-danger"
                  >
                    <font-awesome-icon icon="ban" /> Dar de Baja Licencia
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

          <!-- Licencia ya dada de baja -->
          <div class="alert alert-warning mt-3" v-else>
            <font-awesome-icon icon="info-circle" />
            <strong>Esta licencia ya está dada de baja</strong>
            <p class="mb-0 mt-2">
              <strong>Fecha de baja:</strong> {{ formatDate(licenciaData.fecha_baja) }}<br>
              <strong>Año:</strong> {{ licenciaData.axo_baja || 'N/A' }}<br>
              <strong>Folio:</strong> {{ licenciaData.folio_baja || 'N/A' }}
            </p>
          </div>
        </div>
      </div>

      <!-- Mensaje cuando no hay licencia buscada -->
      <div class="municipal-card text-center" v-if="!licenciaData && !primeraBusqueda">
        <div class="municipal-card-body py-5">
          <font-awesome-icon icon="search" size="3x" class="text-muted mb-3" />
          <h5 class="text-muted">Busque una licencia para dar de baja</h5>
          <p class="text-muted">Ingrese el número de licencia en el panel de búsqueda.</p>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>{{ loadingMessage }}</p>
      </div>
    </div>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <div class="toast-content">
        <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
        <span class="toast-message">{{ toast.message }}</span>
      </div>
      <span v-if="toast.duration" class="toast-duration">{{ toast.duration }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'bajaLicenciafrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Swal from 'sweetalert2'

const router = useRouter()
const { execute } = useApi()
const {
  loading,
  setLoading,
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError,
  loadingMessage
} = useLicenciasErrorHandler()

// Estado
const showDocumentation = ref(false)
const showBusqueda = ref(true)
const primeraBusqueda = ref(false)
const searchLicencia = ref(null)
const licenciaData = ref(null)
const anuncios = ref([])
const adeudos = ref([])
const totalAdeudos = ref(0)

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
  router.push('/padron-licencias/consulta-licencias')
}

const buscarLicencia = async () => {
  if (!searchLicencia.value) {
    showToast('warning', 'Ingrese el número de licencia')
    return
  }

  setLoading(true, 'Buscando licencia...')
  primeraBusqueda.value = true
  showBusqueda.value = false

  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_consulta_licencia',
      'padron_licencias',
      [{ nombre: 'p_licencia', valor: searchLicencia.value, tipo: 'integer' }],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1
      ? `${((endTime - startTime)).toFixed(0)}ms`
      : `${duration}s`

    if (response && response.result && response.result.length > 0) {
      licenciaData.value = response.result[0]

      // Cargar anuncios ligados y adeudos pendientes
      await Promise.all([cargarAnuncios(), cargarAdeudos()])

      toast.value.duration = durationText
      showToast('success', 'Licencia encontrada')
    } else {
      licenciaData.value = null
      anuncios.value = []
      adeudos.value = []
      totalAdeudos.value = 0
      showToast('warning', 'No se encontró la licencia')
    }
  } catch (error) {
    handleApiError(error)
    licenciaData.value = null
    anuncios.value = []
  } finally {
    setLoading(false)
  }
}

const cargarAnuncios = async () => {
  if (!licenciaData.value) return

  try {
    const response = await execute(
      'sp_consulta_anuncios_licencia',
      'padron_licencias',
      [{ nombre: 'p_licencia', valor: searchLicencia.value, tipo: 'integer' }],
      'guadalajara'
    )

    if (response && response.result) {
      anuncios.value = response.result
    } else {
      anuncios.value = []
    }
  } catch (error) {
    anuncios.value = []
  }
}

const cargarAdeudos = async () => {
  if (!licenciaData.value) return

  try {
    const response = await execute(
      'sp_consulta_adeudos_licencia',
      'padron_licencias',
      [{ nombre: 'p_id_licencia', valor: licenciaData.value.id_licencia, tipo: 'integer' }],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      adeudos.value = response.result
      // Calcular total de adeudos pendientes
      totalAdeudos.value = adeudos.value.reduce((sum, a) => {
        const total = parseFloat(a.total) || parseFloat(a.importe) || 0
        return sum + total
      }, 0)
    } else {
      adeudos.value = []
      totalAdeudos.value = 0
    }
  } catch (error) {
    adeudos.value = []
    totalAdeudos.value = 0
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

  // Verificar si hay anuncios bloqueados
  const anunciosBloqueados = anuncios.value.filter(a => a.bloqueado > 0 && a.vigente === 'V')
  if (anunciosBloqueados.length > 0) {
    await Swal.fire({
      icon: 'error',
      title: 'Anuncios Bloqueados',
      html: `No se puede dar de baja la licencia porque tiene ${anunciosBloqueados.length} anuncio(s) bloqueado(s):<br><br>` +
            anunciosBloqueados.map(a => `• Anuncio #${a.anuncio}`).join('<br>'),
      confirmButtonColor: '#ea8215'
    })
    return
  }

  // Verificar si hay adeudos pendientes
  if (adeudos.value.length > 0 && totalAdeudos.value > 0) {
    const formatCurrency = (value) => {
      return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value)
    }

    const resultAdeudos = await Swal.fire({
      icon: 'warning',
      title: 'Adeudos Pendientes',
      html: `
        <div class="text-start">
          <p>Esta licencia tiene <strong>${adeudos.value.length} adeudo(s) pendiente(s)</strong> por un total de:</p>
          <h3 class="text-danger text-center my-3">${formatCurrency(totalAdeudos.value)}</h3>
          <div style="max-height: 200px; overflow-y: auto;">
            <table class="table table-sm table-striped">
              <thead>
                <tr>
                  <th>Concepto</th>
                  <th>Período</th>
                  <th class="text-end">Importe</th>
                </tr>
              </thead>
              <tbody>
                ${adeudos.value.slice(0, 10).map(a => `
                  <tr>
                    <td>${a.concepto || a.descripcion || 'N/A'}</td>
                    <td>${a.periodo || a.anio || 'N/A'}</td>
                    <td class="text-end">${formatCurrency(parseFloat(a.total) || parseFloat(a.importe) || 0)}</td>
                  </tr>
                `).join('')}
                ${adeudos.value.length > 10 ? `<tr><td colspan="3" class="text-center text-muted">... y ${adeudos.value.length - 10} más</td></tr>` : ''}
              </tbody>
            </table>
          </div>
          <p class="text-danger mt-3"><strong>¿Desea continuar con la baja a pesar de los adeudos?</strong></p>
          <p class="text-muted small">Nota: Esta acción requiere autorización especial.</p>
        </div>
      `,
      showCancelButton: true,
      showDenyButton: true,
      confirmButtonColor: '#dc3545',
      denyButtonColor: '#ea8215',
      cancelButtonColor: '#6c757d',
      confirmButtonText: 'Continuar con Baja',
      denyButtonText: 'Ver Estado de Cuenta',
      cancelButtonText: 'Cancelar',
      width: '600px'
    })

    if (resultAdeudos.isDenied) {
      // Redirigir a estado de cuenta
      router.push(`/padron-licencias/estado-cuenta/${licenciaData.value.id_licencia}`)
      return
    }

    if (!resultAdeudos.isConfirmed) {
      return
    }

    // Si continúa, requerir autorización especial
    const authResult = await Swal.fire({
      icon: 'warning',
      title: 'Autorización Requerida',
      html: `
        <p>La baja de licencias con adeudos pendientes requiere <strong>autorización de un supervisor</strong>.</p>
        <p>Ingrese las credenciales del supervisor:</p>
      `,
      input: 'text',
      inputPlaceholder: 'Usuario supervisor',
      showCancelButton: true,
      confirmButtonText: 'Validar',
      cancelButtonText: 'Cancelar',
      confirmButtonColor: '#ea8215',
      preConfirm: async (usuario) => {
        if (!usuario) {
          Swal.showValidationMessage('Ingrese el usuario supervisor')
          return false
        }

        // Solicitar contraseña del supervisor
        const { value: password } = await Swal.fire({
          title: 'Contraseña del Supervisor',
          input: 'password',
          inputPlaceholder: 'Contraseña',
          showCancelButton: true,
          confirmButtonColor: '#ea8215'
        })

        if (!password) return false

        // Verificar credenciales del supervisor
        try {
          const response = await execute(
            'sp_validar_supervisor_baja',
            'padron_licencias',
            [
              { nombre: 'p_usuario', valor: usuario, tipo: 'string' },
              { nombre: 'p_password', valor: password, tipo: 'string' }
            ],
            'guadalajara'
          )

          if (response && response.result && response.result[0]?.autorizado) {
            return { usuario, autorizado: true }
          } else {
            Swal.showValidationMessage('Usuario no autorizado o credenciales inválidas')
            return false
          }
        } catch (error) {
          Swal.showValidationMessage('Error al validar credenciales')
          return false
        }
      }
    })

    if (!authResult.isConfirmed || !authResult.value?.autorizado) {
      showToast('warning', 'Baja cancelada - Se requiere autorización')
      return
    }

    // Registrar quién autorizó
    bajaForm.value.autorizadoPor = authResult.value.usuario
  }

  // Confirmación
  const anunciosVigentes = anuncios.value.filter(a => a.vigente === 'V')
  const mensajeAnuncios = anunciosVigentes.length > 0
    ? `<p class="text-warning"><strong>${anunciosVigentes.length} anuncio(s) vigente(s) también serán dados de baja.</strong></p>`
    : ''

  const result = await Swal.fire({
    icon: 'warning',
    title: '¿Dar de baja licencia?',
    html: `
      <p>¿Está seguro de dar de baja la licencia <strong>#${licenciaData.value.licencia}</strong>?</p>
      <p><strong>Propietario:</strong> ${licenciaData.value.propietario}</p>
      <p><strong>Motivo:</strong> ${bajaForm.value.motivo}</p>
      ${mensajeAnuncios}
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
      'sp_verifica_firma',
      'padron_licencias',
      [
        { nombre: 'p_usuario', valor: localStorage.getItem('usuario') || '', tipo: 'string' },
        { nombre: 'p_firma', valor: firma, tipo: 'string' }
      ],
      'guadalajara'
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
    handleApiError(error)
    return { success: false }
  }
}

const ejecutarBaja = async () => {
  const usuario = localStorage.getItem('usuario') || 'sistema'

  setLoading(true, 'Procesando baja de licencia...')

  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_baja_licencia',
      'padron_licencias',
      [
        { nombre: 'p_id_licencia', valor: licenciaData.value.id_licencia, tipo: 'integer' },
        { nombre: 'p_motivo', valor: bajaForm.value.motivo, tipo: 'string' },
        { nombre: 'p_anio', valor: bajaForm.value.bajaError ? null : bajaForm.value.anio, tipo: 'integer' },
        { nombre: 'p_folio', valor: bajaForm.value.bajaError ? null : bajaForm.value.folio, tipo: 'integer' },
        { nombre: 'p_baja_error', valor: bajaForm.value.bajaError, tipo: 'boolean' },
        { nombre: 'p_usuario', valor: usuario, tipo: 'string' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1
      ? `${((endTime - startTime)).toFixed(0)}ms`
      : `${duration}s`

    setLoading(false)

    if (response && response.result && response.result.length > 0) {
      const resultado = response.result[0]

      if (resultado.success) {
        await Swal.fire({
          icon: 'success',
          title: 'Baja Registrada',
          text: resultado.message,
          confirmButtonColor: '#ea8215'
        })

        toast.value.duration = durationText
        showToast('success', 'Baja procesada correctamente')

        // Limpiar y buscar de nuevo para mostrar el estado actualizado
        await buscarLicencia()
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
    setLoading(false)
    handleApiError(error)
  }
}

const cancelar = () => {
  searchLicencia.value = null
  licenciaData.value = null
  anuncios.value = []
  adeudos.value = []
  totalAdeudos.value = 0
  primeraBusqueda.value = false
  showBusqueda.value = true
  bajaForm.value = {
    motivo: '',
    anio: new Date().getFullYear(),
    folio: null,
    bajaError: false,
    autorizadoPor: null
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
  const savedSearch = localStorage.getItem('bajalicencia_search')
  if (savedSearch) {
    searchLicencia.value = parseInt(savedSearch)
    localStorage.removeItem('bajalicencia_search')
    buscarLicencia()
  }
})
</script>
