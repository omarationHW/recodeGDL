<template>
  <div class="module-view">
    <!-- Header -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="edit" />
      </div>
      <div class="module-view-info">
        <h1>Actualización de Datos</h1>
        <p>Otras Obligaciones - Modificación de datos generales y específicos</p>
      </div>
      <button class="btn-help-icon" @click="openDocumentation" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" @click="goBack">
          <font-awesome-icon icon="arrow-left" /> Salir
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Sección de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            {{ labelBusqueda }}
          </h5>
        </div>

        <div class="municipal-card-body">
          <div class="form-row">
            <!-- Campo de búsqueda dinámico según el tipo de tabla -->
            <div class="form-group" v-if="tipoTabla !== 3">
              <label class="municipal-form-label">{{ etiquetaControl }}</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="busqueda.numeroExpediente"
                @keyup.enter="buscarRegistro"
                placeholder="Ingrese número de expediente"
                maxlength="10"
              >
            </div>

            <!-- Para mercados (tipo 3) se usa número de local + letra -->
            <div class="form-group" v-if="tipoTabla === 3">
              <label class="municipal-form-label">Número de Local</label>
              <input
                type="text"
                class="municipal-form-control input-numero-local"
                v-model="busqueda.numeroLocal"
                @keyup.enter="focusLetra"
                placeholder="Número"
                maxlength="3"
              >
              <input
                type="text"
                class="municipal-form-control input-letra-local"
                v-model="busqueda.letra"
                ref="letraInput"
                @keyup.enter="buscarRegistro"
                placeholder="Letra"
                maxlength="1"
              >
            </div>

            <div class="form-group">
              <label class="municipal-form-label">&nbsp;</label>
              <button
                class="btn-municipal-primary"
                @click="buscarRegistro"
                :disabled="loading"
              >
                <font-awesome-icon icon="search" />
                Buscar
              </button>
            </div>
          </div>

          <div class="alert alert-info" v-if="nombreTabla">
            <strong>{{ nombreTabla }}</strong>
          </div>
        </div>
      </div>

      <!-- Panel de datos encontrados -->
      <div class="municipal-card" v-if="registroActual">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="info-circle" />
            Datos del Registro
          </h5>
          <span class="badge" :class="getBadgeClass(registroActual.statusregistro)">
            {{ registroActual.statusregistro }}
          </span>
        </div>

        <div class="municipal-card-body">
          <div class="info-grid">
            <div class="info-item">
              <strong>{{ etiquetas.concesionario || 'Concesionario' }}:</strong>
              <span>{{ registroActual.concesionario }}</span>
            </div>
            <div class="info-item">
              <strong>{{ etiquetas.ubicacion || 'Ubicación' }}:</strong>
              <span>{{ registroActual.ubicacion }}</span>
            </div>
            <div class="info-item">
              <strong>{{ etiquetas.nombre_comercial || 'Nombre Comercial' }}:</strong>
              <span>{{ registroActual.nomcomercial }}</span>
            </div>
            <div class="info-item">
              <strong>{{ etiquetas.lugar || 'Lugar' }}:</strong>
              <span>{{ registroActual.lugar }}</span>
            </div>
            <div class="info-item">
              <strong>{{ etiquetas.superficie || 'Superficie' }}:</strong>
              <span>{{ registroActual.superficie }} m²</span>
            </div>
            <div class="info-item">
              <strong>{{ etiquetas.unidad || 'Unidades' }}:</strong>
              <span>{{ registroActual.unidades }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Opciones de actualización -->
      <div class="municipal-card" v-if="registroActual && registroActual.statusregistro === 'VIGENTE'">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="cogs" />
            Opciones de Actualización
          </h5>
        </div>

        <div class="municipal-card-body">
          <div class="form-group">
            <label class="municipal-form-label">Seleccione qué desea actualizar:</label>
            <select class="municipal-form-control" v-model="opcionSeleccionada" @change="cambiarOpcion">
              <option :value="0">Concesionario / Nombre</option>
              <option :value="1">Ubicación</option>
              <option :value="2">Licencia</option>
              <option :value="3">Nombre Comercial</option>
              <option :value="4">Lugar</option>
              <option :value="5">Observaciones</option>
              <option :value="6">Superficie</option>
              <option :value="7">Tipo de Local / Unidades</option>
              <option :value="8">Inicio de Obligación</option>
              <option :value="9">Multas Relacionadas</option>
              <option :value="10">Suspensión</option>
            </select>
          </div>

          <!-- Formulario según opción seleccionada -->

          <!-- Opción 0: Concesionario -->
          <div v-if="opcionSeleccionada === 0" class="update-form">
            <h6>Actualizar Concesionario</h6>
            <div class="form-group">
              <label class="municipal-form-label">Nuevo Concesionario</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formData.concesionario"
                maxlength="100"
              >
            </div>
            <button class="btn-municipal-primary" @click="aplicarCambio" :disabled="saving">
              <font-awesome-icon icon="check" />
              {{ saving ? 'Guardando...' : 'Aplicar Cambio' }}
            </button>
          </div>

          <!-- Opción 1: Ubicación -->
          <div v-if="opcionSeleccionada === 1" class="update-form">
            <h6>Actualizar Ubicación</h6>
            <div class="form-group">
              <label class="municipal-form-label">Nueva Ubicación</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formData.ubicacion"
                maxlength="255"
              >
            </div>
            <button class="btn-municipal-primary" @click="aplicarCambio" :disabled="saving">
              <font-awesome-icon icon="check" />
              {{ saving ? 'Guardando...' : 'Aplicar Cambio' }}
            </button>
          </div>

          <!-- Opción 2: Licencia -->
          <div v-if="opcionSeleccionada === 2" class="update-form">
            <h6>Actualizar Licencia</h6>
            <div class="form-group">
              <label class="municipal-form-label">Nueva Licencia</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="formData.licencia"
                maxlength="7"
              >
            </div>
            <button class="btn-municipal-primary" @click="aplicarCambio" :disabled="saving">
              <font-awesome-icon icon="check" />
              {{ saving ? 'Guardando...' : 'Aplicar Cambio' }}
            </button>
          </div>

          <!-- Opción 3: Nombre Comercial -->
          <div v-if="opcionSeleccionada === 3" class="update-form">
            <h6>Actualizar Nombre Comercial</h6>
            <div class="form-group">
              <label class="municipal-form-label">Nuevo Nombre Comercial</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formData.nomcomercial"
                maxlength="100"
              >
            </div>
            <button class="btn-municipal-primary" @click="aplicarCambio" :disabled="saving">
              <font-awesome-icon icon="check" />
              {{ saving ? 'Guardando...' : 'Aplicar Cambio' }}
            </button>
          </div>

          <!-- Opción 4: Lugar -->
          <div v-if="opcionSeleccionada === 4" class="update-form">
            <h6>Actualizar Lugar</h6>
            <div class="form-group">
              <label class="municipal-form-label">Nuevo Lugar</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formData.lugar"
                maxlength="255"
              >
            </div>
            <button class="btn-municipal-primary" @click="aplicarCambio" :disabled="saving">
              <font-awesome-icon icon="check" />
              {{ saving ? 'Guardando...' : 'Aplicar Cambio' }}
            </button>
          </div>

          <!-- Opción 5: Observaciones -->
          <div v-if="opcionSeleccionada === 5" class="update-form">
            <h6>Actualizar Observaciones</h6>
            <div class="form-group">
              <label class="municipal-form-label">Nuevas Observaciones</label>
              <textarea
                class="municipal-form-control"
                v-model="formData.obs"
                maxlength="255"
                rows="3"
              ></textarea>
            </div>
            <button class="btn-municipal-primary" @click="aplicarCambio" :disabled="saving">
              <font-awesome-icon icon="check" />
              {{ saving ? 'Guardando...' : 'Aplicar Cambio' }}
            </button>
          </div>

          <!-- Opción 6: Superficie -->
          <div v-if="opcionSeleccionada === 6" class="update-form">
            <h6>Actualizar Superficie</h6>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Nueva Superficie (m²)</label>
                <input
                  type="number"
                  step="0.01"
                  class="municipal-form-control"
                  v-model.number="formData.superficie"
                  maxlength="7"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Año de Aplicación</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="formData.axoInicio"
                  maxlength="4"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Mes de Aplicación</label>
                <select class="municipal-form-control" v-model.number="formData.mesInicio">
                  <option :value="1">01 - Enero</option>
                  <option :value="2">02 - Febrero</option>
                  <option :value="3">03 - Marzo</option>
                  <option :value="4">04 - Abril</option>
                  <option :value="5">05 - Mayo</option>
                  <option :value="6">06 - Junio</option>
                  <option :value="7">07 - Julio</option>
                  <option :value="8">08 - Agosto</option>
                  <option :value="9">09 - Septiembre</option>
                  <option :value="10">10 - Octubre</option>
                  <option :value="11">11 - Noviembre</option>
                  <option :value="12">12 - Diciembre</option>
                </select>
              </div>
            </div>
            <button class="btn-municipal-primary" @click="aplicarCambio" :disabled="saving">
              <font-awesome-icon icon="check" />
              {{ saving ? 'Guardando...' : 'Aplicar Cambio' }}
            </button>
          </div>

          <!-- Opción 7: Tipo de Local / Unidades -->
          <div v-if="opcionSeleccionada === 7" class="update-form">
            <h6>Actualizar Tipo de Local</h6>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Nuevo Tipo de Local</label>
                <select class="municipal-form-control" v-model="formData.unidades">
                  <option v-for="tipo in tiposLocal" :key="tipo.cve_tab" :value="tipo.descripcion">
                    {{ tipo.descripcion }}
                  </option>
                </select>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Año de Aplicación</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="formData.axoInicio"
                  maxlength="4"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Mes de Aplicación</label>
                <select class="municipal-form-control" v-model.number="formData.mesInicio">
                  <option :value="1">01 - Enero</option>
                  <option :value="2">02 - Febrero</option>
                  <option :value="3">03 - Marzo</option>
                  <option :value="4">04 - Abril</option>
                  <option :value="5">05 - Mayo</option>
                  <option :value="6">06 - Junio</option>
                  <option :value="7">07 - Julio</option>
                  <option :value="8">08 - Agosto</option>
                  <option :value="9">09 - Septiembre</option>
                  <option :value="10">10 - Octubre</option>
                  <option :value="11">11 - Noviembre</option>
                  <option :value="12">12 - Diciembre</option>
                </select>
              </div>
            </div>
            <button class="btn-municipal-primary" @click="aplicarCambio" :disabled="saving">
              <font-awesome-icon icon="check" />
              {{ saving ? 'Guardando...' : 'Aplicar Cambio' }}
            </button>
          </div>

          <!-- Opción 8: Inicio de Obligación -->
          <div v-if="opcionSeleccionada === 8" class="update-form">
            <h6>Actualizar Inicio de Obligación</h6>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Año de Inicio</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="formData.axoInicio"
                  maxlength="4"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Mes de Inicio</label>
                <select class="municipal-form-control" v-model.number="formData.mesInicio">
                  <option :value="1">01 - Enero</option>
                  <option :value="2">02 - Febrero</option>
                  <option :value="3">03 - Marzo</option>
                  <option :value="4">04 - Abril</option>
                  <option :value="5">05 - Mayo</option>
                  <option :value="6">06 - Junio</option>
                  <option :value="7">07 - Julio</option>
                  <option :value="8">08 - Agosto</option>
                  <option :value="9">09 - Septiembre</option>
                  <option :value="10">10 - Octubre</option>
                  <option :value="11">11 - Noviembre</option>
                  <option :value="12">12 - Diciembre</option>
                </select>
              </div>
            </div>
            <button class="btn-municipal-primary" @click="aplicarCambio" :disabled="saving">
              <font-awesome-icon icon="check" />
              {{ saving ? 'Guardando...' : 'Aplicar Cambio' }}
            </button>
          </div>

          <!-- Opción 9: Multas Relacionadas -->
          <div v-if="opcionSeleccionada === 9" class="update-form">
            <h6>Multas Relacionadas</h6>

            <!-- Formulario para agregar multa -->
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Dependencia</label>
                <select class="municipal-form-control" v-model.number="multaForm.dependencia">
                  <option v-for="dep in dependencias" :key="dep.id_dependencia" :value="dep.id_dependencia">
                    {{ dep.id_dependencia }} - {{ dep.descripcion }}
                  </option>
                </select>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Año Acta</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="multaForm.axoActa"
                  maxlength="4"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Número Acta</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="multaForm.numActa"
                  maxlength="10"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">&nbsp;</label>
                <button class="btn-municipal-primary" @click="agregarMulta" :disabled="saving">
                  <font-awesome-icon icon="plus" />
                  Alta
                </button>
              </div>
            </div>

            <!-- Tabla de multas -->
            <div class="table-responsive" v-if="multasRelacionadas.length > 0">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr>
                    <th>Dependencia</th>
                    <th>Año Acta</th>
                    <th>Núm. Acta</th>
                    <th>Estado</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(multa, index) in multasRelacionadas" :key="index" class="row-hover">
                    <td>{{ multa.dep }} - {{ multa.nom_dep }}</td>
                    <td>{{ multa.axo_acta }}</td>
                    <td>{{ multa.num_acta }}</td>
                    <td>{{ multa.expression }}</td>
                    <td>
                      <button
                        class="btn-icon-success"
                        @click="actualizarMulta('A', multa)"
                        title="Reactivar"
                      >
                        <font-awesome-icon icon="check-circle" />
                      </button>
                      <button
                        class="btn-icon-warning"
                        @click="actualizarMulta('C', multa)"
                        title="Cancelar"
                      >
                        <font-awesome-icon icon="ban" />
                      </button>
                      <button
                        class="btn-icon-info"
                        @click="actualizarMulta('P', multa)"
                        title="Pagada"
                      >
                        <font-awesome-icon icon="dollar-sign" />
                      </button>
                      <button
                        class="btn-icon-danger"
                        @click="actualizarMulta('D', multa)"
                        title="Eliminar/Desligar"
                      >
                        <font-awesome-icon icon="trash" />
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div v-else class="text-center text-muted">
              <p>No hay multas relacionadas</p>
            </div>
          </div>

          <!-- Opción 10: Suspensión -->
          <div v-if="opcionSeleccionada === 10" class="update-form">
            <h6>Gestión de Suspensiones</h6>

            <!-- Formulario para crear suspensión -->
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Año</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="suspensionForm.axo"
                  maxlength="4"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Mes</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="suspensionForm.mes"
                  min="1"
                  max="12"
                  maxlength="2"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Fecha Suspensión</label>
                <input
                  type="date"
                  class="municipal-form-control"
                  v-model="suspensionForm.fechaSuspension"
                >
              </div>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Descripción / Motivo</label>
              <textarea
                class="municipal-form-control"
                v-model="suspensionForm.descripcion"
                rows="3"
                maxlength="500"
              ></textarea>
            </div>
            <button class="btn-municipal-primary" @click="crearSuspension" :disabled="saving">
              <font-awesome-icon icon="pause-circle" />
              {{ saving ? 'Guardando...' : 'Registrar Suspensión' }}
            </button>

            <!-- Tabla de suspensiones -->
            <div class="table-responsive mt-3" v-if="suspensiones.length > 0">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr>
                    <th>Año Inicio</th>
                    <th>Mes Inicio</th>
                    <th>Año Fin</th>
                    <th>Mes Fin</th>
                    <th>Descripción</th>
                    <th>Estado</th>
                    <th>Fecha Alta</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(susp, index) in suspensiones" :key="index" class="row-hover">
                    <td>{{ susp.axo_inicio }}</td>
                    <td>{{ susp.mes_inicio }}</td>
                    <td>{{ susp.axo_fin || '-' }}</td>
                    <td>{{ susp.mes_fin || '-' }}</td>
                    <td>{{ susp.descripcion }}</td>
                    <td>
                      <span class="badge" :class="susp.estado === 'S' ? 'badge-warning' : 'badge-secondary'">
                        {{ susp.estado === 'S' ? 'Suspendido' : 'Cancelado' }}
                      </span>
                    </td>
                    <td>{{ formatDate(susp.fecha_alta) }}</td>
                    <td>
                      <button
                        v-if="susp.estado === 'S'"
                        class="btn-icon-danger"
                        @click="cancelarSuspension(susp)"
                        title="Cancelar Suspensión"
                      >
                        <font-awesome-icon icon="times-circle" />
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div v-else class="text-center text-muted">
              <p>No hay suspensiones registradas</p>
            </div>
          </div>

        </div>
      </div>

      <!-- Mensaje si el registro no está vigente -->
      <div class="municipal-card" v-if="registroActual && registroActual.statusregistro !== 'VIGENTE'">
        <div class="municipal-card-body">
          <div class="alert alert-warning">
            <font-awesome-icon icon="exclamation-triangle" />
            Este registro está en estado <strong>{{ registroActual.statusregistro }}</strong>.
            No se pueden realizar modificaciones.
          </div>
        </div>
      </div>

      <!-- Loading overlay -->
      <div v-if="loading" class="loading-overlay">
        <div class="loading-spinner">
          <div class="spinner"></div>
          <p>Cargando datos...</p>
        </div>
      </div>
    </div>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>

  <DocumentationModal
    :show="showDocumentation"
    :componentName="'GActualiza'"
    :moduleName="'otras_obligaciones'"
    @close="closeDocumentation"
  />
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Swal from 'sweetalert2'

const router = useRouter()
const route = useRoute()
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const {
  loading,
  setLoading,
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const tipoTabla = ref(route.params.tipo || route.query.tipo || 1) // 1=Tianguis, 2=VíaPública, 3=Mercados, 4=Centrales, 5=Otros
const nombreTabla = ref('')
const etiquetas = ref({})
const tiposLocal = ref([])
const dependencias = ref([])
const registroActual = ref(null)
const multasRelacionadas = ref([])
const suspensiones = ref([])
const opcionSeleccionada = ref(0)
const saving = ref(false)
const letraInput = ref(null)

// Búsqueda
const busqueda = ref({
  numeroExpediente: '',
  numeroLocal: '',
  letra: ''
})

// Formularios
const formData = ref({
  concesionario: '',
  ubicacion: '',
  licencia: 0,
  nomcomercial: '',
  lugar: '',
  obs: '',
  superficie: 0,
  unidades: '',
  axoInicio: new Date().getFullYear(),
  mesInicio: new Date().getMonth() + 1
})

const multaForm = ref({
  dependencia: null,
  axoActa: new Date().getFullYear(),
  numActa: 0
})

const suspensionForm = ref({
  axo: new Date().getFullYear(),
  mes: new Date().getMonth() + 1,
  fechaSuspension: new Date().toISOString().split('T')[0],
  descripcion: ''
})

// Computed
const labelBusqueda = computed(() => {
  return `CAMBIOS DE: ${nombreTabla.value || 'Cargando...'}`
})

const etiquetaControl = computed(() => {
  return etiquetas.value.etiq_control || 'Número de Control'
})

// Métodos
const goBack = () => {
  router.push('/otras_obligaciones')
}

const focusLetra = () => {
  if (letraInput.value) {
    letraInput.value.focus()
  }
}

const getBadgeClass = (status) => {
  switch (status) {
    case 'VIGENTE':
      return 'badge-success'
    case 'SUSPENSION':
      return 'badge-warning'
    case 'CANCELADO':
      return 'badge-danger'
    default:
      return 'badge-secondary'
  }
}

const formatDate = (dateString) => {
  if (!dateString) return '-'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-MX')
  } catch (error) {
    return dateString
  }
}

// Cargar etiquetas y tablas
const loadEtiquetas = async () => {
  try {
    const response = await execute(
      'sp_otras_oblig_get_etiquetas',
      'otras_obligaciones',
      [{ nombre: 'par_tab', valor: tipoTabla.value, tipo: 'string' }],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      etiquetas.value = response.result[0]
    }
  } catch (error) {
    console.error('Error al cargar etiquetas:', error)
  }
}

const loadTablas = async () => {
  try {
    const response = await execute(
      'sp_otras_oblig_get_tablas',
      'otras_obligaciones',
      [{ nombre: 'par_tab', valor: tipoTabla.value, tipo: 'string' }],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      nombreTabla.value = response.result[0].nombre
      tiposLocal.value = response.result
    }
  } catch (error) {
    console.error('Error al cargar tablas:', error)
  }
}

const loadDependencias = async () => {
  try {
    const response = await execute(
      'SP_GACTUALIZA_DEPENDENCIAS_GET',
      'otras_obligaciones',
      [],
      'guadalajara'
    )

    if (response && response.result) {
      dependencias.value = response.result
      if (dependencias.value.length > 0) {
        multaForm.value.dependencia = dependencias.value[0].id_dependencia
      }
    }
  } catch (error) {
    console.error('Error al cargar dependencias:', error)
  }
}

// Buscar registro
const buscarRegistro = async () => {
  let control = ''

  if (tipoTabla.value === 3) {
    // Mercados: número-letra
    if (!busqueda.value.numeroLocal) {
      await Swal.fire({
        icon: 'warning',
        title: 'Campo requerido',
        text: 'Ingrese el número de local',
        confirmButtonColor: '#ea8215'
      })
      return
    }
    control = busqueda.value.numeroLocal
    if (busqueda.value.letra) {
      control += '-' + busqueda.value.letra
    }
  } else {
    // Otros tipos: expediente con abreviatura
    if (!busqueda.value.numeroExpediente) {
      await Swal.fire({
        icon: 'warning',
        title: 'Campo requerido',
        text: 'Ingrese el número de expediente',
        confirmButtonColor: '#ea8215'
      })
      return
    }
    control = (etiquetas.value.abreviatura || '') + busqueda.value.numeroExpediente
  }

  setLoading(true, 'Buscando registro...')

  try {
    const response = await execute(
      'SP_GACTUALIZA_DATOS_GET',
      'otras_obligaciones',
      [
        { nombre: 'par_tab', valor: tipoTabla.value.toString(), tipo: 'string' },
        { nombre: 'par_control', valor: control, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      const data = response.result[0]

      if (data.status === -1) {
        await Swal.fire({
          icon: 'info',
          title: 'No encontrado',
          text: data.concepto_status,
          confirmButtonColor: '#ea8215'
        })
        registroActual.value = null
      } else {
        registroActual.value = data

        // Cargar datos adicionales
        await loadMultasRelacionadas()
        await loadSuspensiones()

        showToast('success', 'Registro encontrado')

        if (data.statusregistro !== 'VIGENTE') {
          await Swal.fire({
            icon: 'warning',
            title: 'Registro no vigente',
            text: `Este registro está en estado ${data.statusregistro}`,
            confirmButtonColor: '#ea8215'
          })
        }
      }
    } else {
      await Swal.fire({
        icon: 'info',
        title: 'No encontrado',
        text: 'No se encontró ningún registro con ese control',
        confirmButtonColor: '#ea8215'
      })
      registroActual.value = null
    }
  } catch (error) {
    handleApiError(error)
    registroActual.value = null
  } finally {
    setLoading(false)
  }
}

// Cargar multas relacionadas
const loadMultasRelacionadas = async () => {
  if (!registroActual.value || !registroActual.value.id_datos) {
    multasRelacionadas.value = []
    return
  }

  try {
    const response = await execute(
      'SP_GACTUALIZA_MULTAS_GET',
      'otras_obligaciones',
      [{ nombre: 'par_Id_34_datos', valor: registroActual.value.id_datos, tipo: 'integer' }],
      'guadalajara'
    )

    if (response && response.result) {
      multasRelacionadas.value = response.result
    } else {
      multasRelacionadas.value = []
    }
  } catch (error) {
    console.error('Error al cargar multas:', error)
    multasRelacionadas.value = []
  }
}

// Cargar suspensiones
const loadSuspensiones = async () => {
  if (!registroActual.value || !registroActual.value.id_datos) {
    suspensiones.value = []
    return
  }

  try {
    const response = await execute(
      'SP_GACTUALIZA_SUSPENSION_GET',
      'otras_obligaciones',
      [{ nombre: 'vid', valor: registroActual.value.id_datos, tipo: 'integer' }],
      'guadalajara'
    )

    if (response && response.result) {
      suspensiones.value = response.result
    } else {
      suspensiones.value = []
    }
  } catch (error) {
    console.error('Error al cargar suspensiones:', error)
    suspensiones.value = []
  }
}

// Cambiar opción
const cambiarOpcion = () => {
  // Resetear formulario
  if (registroActual.value) {
    formData.value.concesionario = registroActual.value.concesionario || ''
    formData.value.ubicacion = registroActual.value.ubicacion || ''
    formData.value.licencia = registroActual.value.licencia || 0
    formData.value.nomcomercial = registroActual.value.nomcomercial || ''
    formData.value.lugar = registroActual.value.lugar || ''
    formData.value.obs = registroActual.value.obs || ''
    formData.value.superficie = registroActual.value.superficie || 0
    formData.value.unidades = registroActual.value.unidades || ''
  }
}

// Aplicar cambio
const aplicarCambio = async () => {
  if (!registroActual.value) {
    showToast('error', 'No hay registro seleccionado')
    return
  }

  // Confirmación
  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar cambio?',
    text: 'Se actualizará el registro con los nuevos datos',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, aplicar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  const startTime = performance.now()
  saving.value = true
  showLoading('Aplicando cambios...')

  try {
    let spName = ''
    let params = []

    // Determinar SP según opción
    if (opcionSeleccionada.value <= 5) {
      // Datos generales
      spName = 'SP_GACTUALIZA_GRALES_UPDATE'
      params = [
        { nombre: 'par_id_34_datos', valor: registroActual.value.id_datos, tipo: 'integer' },
        { nombre: 'par_conces', valor: formData.value.concesionario || '', tipo: 'string' },
        { nombre: 'par_ubica', valor: formData.value.ubicacion || '', tipo: 'string' },
        { nombre: 'par_lic', valor: formData.value.licencia || 0, tipo: 'integer' },
        { nombre: 'par_nomcom', valor: formData.value.nomcomercial || 'nada', tipo: 'string' },
        { nombre: 'par_lugar', valor: formData.value.lugar || 'nada', tipo: 'string' },
        { nombre: 'par_obs', valor: formData.value.obs || 'nada', tipo: 'string' },
        { nombre: 'par_usuario', valor: 'SISTEMA', tipo: 'string' }
      ]
    } else if (opcionSeleccionada.value === 6) {
      // Superficie
      spName = 'SP_GACTUALIZA_SUP_UPDATE'
      params = [
        { nombre: 'par_tabla', valor: tipoTabla.value.toString(), tipo: 'string' },
        { nombre: 'par_id_34_datos', valor: registroActual.value.id_datos, tipo: 'integer' },
        { nombre: 'par_sup', valor: formData.value.superficie, tipo: 'decimal' },
        { nombre: 'par_Descrip', valor: registroActual.value.unidades, tipo: 'string' },
        { nombre: 'par_Axo_Ini', valor: formData.value.axoInicio, tipo: 'integer' },
        { nombre: 'par_Mes_Ini', valor: formData.value.mesInicio, tipo: 'integer' },
        { nombre: 'par_usuario', valor: 'SISTEMA', tipo: 'string' }
      ]
    } else if (opcionSeleccionada.value === 7) {
      // Unidades
      spName = 'SP_GACTUALIZA_UNIDADES_UPDATE'
      params = [
        { nombre: 'par_tabla', valor: tipoTabla.value.toString(), tipo: 'string' },
        { nombre: 'par_id_34_datos', valor: registroActual.value.id_datos, tipo: 'integer' },
        { nombre: 'par_sup', valor: registroActual.value.superficie, tipo: 'decimal' },
        { nombre: 'par_Descrip', valor: formData.value.unidades, tipo: 'string' },
        { nombre: 'par_Axo_Ini', valor: formData.value.axoInicio, tipo: 'integer' },
        { nombre: 'par_Mes_Ini', valor: formData.value.mesInicio, tipo: 'integer' },
        { nombre: 'par_usuario', valor: 'SISTEMA', tipo: 'string' }
      ]
    } else if (opcionSeleccionada.value === 8) {
      // Inicio obligación
      spName = 'SP_GACTUALIZA_OBLIG_UPDATE'
      params = [
        { nombre: 'par_tabla', valor: tipoTabla.value.toString(), tipo: 'string' },
        { nombre: 'par_id_34_datos', valor: registroActual.value.id_datos, tipo: 'integer' },
        { nombre: 'par_sup', valor: registroActual.value.superficie, tipo: 'decimal' },
        { nombre: 'par_Descrip', valor: registroActual.value.unidades, tipo: 'string' },
        { nombre: 'par_Axo_Ini', valor: formData.value.axoInicio, tipo: 'integer' },
        { nombre: 'par_Mes_Ini', valor: formData.value.mesInicio, tipo: 'integer' },
        { nombre: 'par_usuario', valor: 'SISTEMA', tipo: 'string' }
      ]
    }

    const response = await execute(spName, 'otras_obligaciones', params, 'guadalajara')

    if (response && response.result && response.result[0]) {
      const data = response.result[0]

      const endTime = performance.now()
      const duration = ((endTime - startTime) / 1000).toFixed(2)
      const timeMessage = duration < 1
        ? `${(duration * 1000).toFixed(0)}ms`
        : `${duration}s`

      if (data.status === 0) {
        await Swal.fire({
          icon: 'success',
          title: 'Actualizado',
          text: data.concepto || 'Cambio aplicado correctamente',
          confirmButtonColor: '#ea8215',
          timer: 2000
        })

        showToast('success', `Cambio aplicado correctamente (${timeMessage})`)

        // Recargar registro
        await buscarRegistro()
      } else {
        await Swal.fire({
          icon: 'error',
          title: 'Error',
          text: data.concepto || 'Error al aplicar el cambio',
          confirmButtonColor: '#ea8215'
        })
      }
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    saving.value = false
    hideLoading()
  }
}

// Agregar multa
const agregarMulta = async () => {
  if (!multaForm.value.dependencia || !multaForm.value.axoActa || !multaForm.value.numActa) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Complete todos los campos para registrar la multa',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  saving.value = true

  try {
    const response = await execute(
      'SP_GACTUALIZA_MULTAS_UPDATE',
      'otras_obligaciones',
      [
        { nombre: 'par_Opc', valor: 'A', tipo: 'string' },
        { nombre: 'par_Dep_Multa', valor: multaForm.value.dependencia, tipo: 'integer' },
        { nombre: 'par_Id_34_datos', valor: registroActual.value.id_datos, tipo: 'integer' },
        { nombre: 'par_AxoActa', valor: multaForm.value.axoActa, tipo: 'integer' },
        { nombre: 'par_NumActa', valor: multaForm.value.numActa, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]) {
      const data = response.result[0]

      await Swal.fire({
        icon: data.status === 0 ? 'success' : 'error',
        title: data.status === 0 ? 'Registrada' : 'Error',
        text: data.leyenda,
        confirmButtonColor: '#ea8215'
      })

      if (data.status === 0) {
        // Recargar multas
        await loadMultasRelacionadas()

        // Resetear formulario
        multaForm.value.axoActa = new Date().getFullYear()
        multaForm.value.numActa = 0
      }
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    saving.value = false
  }
}

// Actualizar multa
const actualizarMulta = async (opc, multa) => {
  const acciones = {
    'A': 'reactivar',
    'C': 'cancelar',
    'P': 'marcar como pagada',
    'D': 'eliminar'
  }

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: `¿Confirmar acción?`,
    text: `¿Desea ${acciones[opc]} esta multa?`,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, confirmar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  saving.value = true

  try {
    const response = await execute(
      'SP_GACTUALIZA_MULTAS_UPDATE',
      'otras_obligaciones',
      [
        { nombre: 'par_Opc', valor: opc, tipo: 'string' },
        { nombre: 'par_Dep_Multa', valor: multa.dep, tipo: 'integer' },
        { nombre: 'par_Id_34_datos', valor: multa.id_34_datos, tipo: 'integer' },
        { nombre: 'par_AxoActa', valor: multa.axo_acta, tipo: 'integer' },
        { nombre: 'par_NumActa', valor: multa.num_acta, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]) {
      const data = response.result[0]

      await Swal.fire({
        icon: data.status === 0 ? 'success' : 'error',
        title: data.status === 0 ? 'Actualizada' : 'Error',
        text: data.leyenda,
        confirmButtonColor: '#ea8215'
      })

      if (data.status === 0) {
        await loadMultasRelacionadas()
      }
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    saving.value = false
  }
}

// Crear suspensión
const crearSuspension = async () => {
  if (!suspensionForm.value.axo || !suspensionForm.value.mes || !suspensionForm.value.descripcion) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Complete todos los campos para registrar la suspensión',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const confirmResult = await Swal.fire({
    icon: 'warning',
    title: '¿Confirmar suspensión?',
    html: `
      <div class="swal-confirm-content">
        <p>Se suspenderá el registro a partir de:</p>
        <ul class="swal-info-list">
          <li><strong>Período:</strong> ${suspensionForm.value.mes}/${suspensionForm.value.axo}</li>
          <li><strong>Fecha:</strong> ${suspensionForm.value.fechaSuspension}</li>
        </ul>
        <p><strong>Motivo:</strong> ${suspensionForm.value.descripcion}</p>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, suspender',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  saving.value = true

  try {
    const response = await execute(
      'SP_GACTUALIZA_SUSPENSION_CREATE',
      'otras_obligaciones',
      [
        { nombre: 'parOpc', valor: 1, tipo: 'integer' },
        { nombre: 'parContrato', valor: registroActual.value.id_datos, tipo: 'integer' },
        { nombre: 'parAxo', valor: suspensionForm.value.axo, tipo: 'integer' },
        { nombre: 'parMes', valor: suspensionForm.value.mes, tipo: 'integer' },
        { nombre: 'parDescrip', valor: suspensionForm.value.descripcion, tipo: 'string' },
        { nombre: 'parUsuario', valor: 'SISTEMA', tipo: 'string' },
        { nombre: 'parFecSusp', valor: suspensionForm.value.fechaSuspension, tipo: 'date' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]) {
      const data = response.result[0]

      await Swal.fire({
        icon: data.codigo_status === 0 ? 'success' : 'error',
        title: data.codigo_status === 0 ? 'Suspendido' : 'Error',
        text: data.mensaje,
        confirmButtonColor: '#ea8215'
      })

      if (data.codigo_status === 0) {
        // Recargar suspensiones y registro
        await loadSuspensiones()
        await buscarRegistro()

        // Resetear formulario
        suspensionForm.value.descripcion = ''
      }
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    saving.value = false
  }
}

// Cancelar suspensión
const cancelarSuspension = async (susp) => {
  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Cancelar suspensión?',
    text: 'El registro se reactivará y volverá al estado VIGENTE',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, cancelar suspensión',
    cancelButtonText: 'No'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  saving.value = true

  try {
    const response = await execute(
      'SP_GACTUALIZA_SUSPENSION_CREATE',
      'otras_obligaciones',
      [
        { nombre: 'parOpc', valor: 2, tipo: 'integer' },
        { nombre: 'parContrato', valor: registroActual.value.id_datos, tipo: 'integer' },
        { nombre: 'parAxo', valor: new Date().getFullYear(), tipo: 'integer' },
        { nombre: 'parMes', valor: new Date().getMonth() + 1, tipo: 'integer' },
        { nombre: 'parDescrip', valor: '', tipo: 'string' },
        { nombre: 'parUsuario', valor: 'SISTEMA', tipo: 'string' },
        { nombre: 'parFecSusp', valor: new Date().toISOString().split('T')[0], tipo: 'date' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]) {
      const data = response.result[0]

      await Swal.fire({
        icon: data.codigo_status === 0 ? 'success' : 'error',
        title: data.codigo_status === 0 ? 'Cancelada' : 'Error',
        text: data.mensaje,
        confirmButtonColor: '#ea8215'
      })

      if (data.codigo_status === 0) {
        // Recargar suspensiones y registro
        await loadSuspensiones()
        await buscarRegistro()
      }
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    saving.value = false
  }
}

// Lifecycle
onMounted(async () => {
  await loadEtiquetas()
  await loadTablas()
  await loadDependencias()
})
</script>

<style scoped>
.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 15px;
  margin-top: 15px;
}

.info-item {
  padding: 10px;
  background-color: #f8f9fa;
  border-radius: 4px;
  border-left: 3px solid #ea8215;
}

.info-item strong {
  display: block;
  color: #666;
  font-size: 0.875rem;
  margin-bottom: 5px;
}

.info-item span {
  color: #333;
  font-size: 1rem;
}

.update-form {
  margin-top: 20px;
  padding: 20px;
  background-color: #f8f9fa;
  border-radius: 8px;
}

.update-form h6 {
  color: #ea8215;
  margin-bottom: 15px;
  font-weight: 600;
}

.badge {
  padding: 5px 10px;
  border-radius: 4px;
  font-size: 0.875rem;
  font-weight: 600;
}

.badge-success {
  background-color: #28a745;
  color: white;
}

.badge-warning {
  background-color: #ffc107;
  color: #333;
}

.badge-danger {
  background-color: #dc3545;
  color: white;
}

.badge-secondary {
  background-color: #6c757d;
  color: white;
}

.badge-purple {
  background-color: #6f42c1;
  color: white;
  margin-left: 10px;
  padding: 3px 8px;
  border-radius: 12px;
  font-size: 0.75rem;
}

.btn-icon-success,
.btn-icon-warning,
.btn-icon-info,
.btn-icon-danger {
  padding: 5px 10px;
  margin: 0 2px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-icon-success {
  background-color: #28a745;
  color: white;
}

.btn-icon-success:hover {
  background-color: #218838;
}

.btn-icon-warning {
  background-color: #ffc107;
  color: #333;
}

.btn-icon-warning:hover {
  background-color: #e0a800;
}

.btn-icon-info {
  background-color: #17a2b8;
  color: white;
}

.btn-icon-info:hover {
  background-color: #138496;
}

.btn-icon-danger {
  background-color: #dc3545;
  color: white;
}

.btn-icon-danger:hover {
  background-color: #c82333;
}

.alert {
  padding: 15px;
  border-radius: 4px;
  margin: 15px 0;
}

.alert-info {
  background-color: #d1ecf1;
  border: 1px solid #bee5eb;
  color: #0c5460;
}

.alert-warning {
  background-color: #fff3cd;
  border: 1px solid #ffeaa7;
  color: #856404;
}

.mt-3 {
  margin-top: 1rem;
}

.input-numero-local {
  width: 150px;
  display: inline-block;
  margin-right: 10px;
}

.input-letra-local {
  width: 80px;
  display: inline-block;
}

/* SweetAlert custom classes */
:deep(.swal-confirm-content) {
  text-align: left;
  padding: 0 20px;
}

:deep(.swal-info-list) {
  list-style: none;
  padding: 0;
}
</style>
