<template>
  <div class="module-view">
    <!-- Header -->
        <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="link" />
      </div>
      <div class="module-view-info">
        <h1>Relación entre Contratos</h1>
        <p>Aseo Contratado - Vinculación de contratos relacionados y gestión de grupos</p>
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
    
      <button
        type="button"
        class="btn-help-icon"
        @click="mostrarAyuda = true"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <!-- Tabs -->
    <div class="municipal-tabs">
      <button
          class="municipal-tab"
          :class="{ active: tabActual === 'vincular' }"
          @click="tabActual = 'vincular'"
        >
          <font-awesome-icon icon="link" />
          Vincular Contratos
        </button>
      <button
          class="municipal-tab"
          :class="{ active: tabActual === 'grupos' }"
          @click="tabActual = 'grupos'"
        >
          <font-awesome-icon icon="layer-group" />
          Grupos de Contratos
        </button>
      <button
          class="municipal-tab"
          :class="{ active: tabActual === 'consulta' }"
          @click="tabActual = 'consulta'"
        >
          <font-awesome-icon icon="search" />
          Consultar Relaciones
        </button>
    </div>

    <!-- Tab: Vincular Contratos -->
    <div v-if="tabActual === 'vincular'">
      <div class="row">
        <!-- Búsqueda de Contratos -->
        <div class="col-md-6">
          <div class="municipal-card shadow-sm mb-3">
            <div class="municipal-card-header">
        <h5>Contrato Principal</h5>
            </div>
<div class="municipal-card-body">
              <div class="form-group">
                <label class="municipal-form-label">Número de Contrato</label>
                <div class="input-group">
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="busqueda.contrato_principal"
                    @keyup.enter="buscarContratoPrincipal"
                    placeholder="Ingrese número de contrato"
                  />
                  <button class="btn-municipal-primary" @click="buscarContratoPrincipal" :disabled="cargando">
                    <font-awesome-icon icon="search" />
                  </button>
                </div>
              </div>

              <div v-if="contratoPrincipal" class="municipal-alert municipal-alert-success">
                <h6 class="alert-heading">
                  <font-awesome-icon icon="check-circle" class="me-2" />
                  Contrato Seleccionado
                </h6>
                <p class="mb-1"><strong>Contrato:</strong> {{ contratoPrincipal.num_contrato }}</p>
                <p class="mb-1"><strong>Contribuyente:</strong> {{ contratoPrincipal.contribuyente }}</p>
                <p class="mb-1"><strong>Domicilio:</strong> {{ contratoPrincipal.domicilio }}</p>
                <p class="mb-0"><strong>Tipo:</strong> {{ formatTipoAseo(contratoPrincipal.tipo_aseo) }}</p>

                <div class="mt-3" v-if="contratosRelacionados.length > 0">
                  <h6>Contratos ya Relacionados: {{ contratosRelacionados.length }}</h6>
                  <div class="list-group list-group-flush" style="max-height: 200px; overflow-y: auto;">
                    <div
                      v-for="rel in contratosRelacionados"
                      :key="rel.num_contrato_relacionado"
                      class="list-group-item d-flex justify-content-between align-items-center p-2"
                    >
                      <div>
                        <strong>{{ rel.num_contrato_relacionado }}</strong><br>
                        <small class="text-muted">{{ rel.tipo_relacion }}</small>
                      </div>
                      <button
                        class="btn btn-sm btn-danger"
                        @click="desvincularContrato(rel)"
                        title="Desvincular"
                      >
                        <font-awesome-icon icon="unlink" />
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Contrato a Vincular -->
        <div class="col-md-6">
          <div class="municipal-card shadow-sm mb-3">
            <div class="municipal-card-header">
        <h5>Contrato a Vincular</h5>
            </div>
            <div class="municipal-card-body">
              <div class="form-group">
                <label class="municipal-form-label">Número de Contrato</label>
                <div class="input-group">
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="busqueda.contrato_vincular"
                    @keyup.enter="buscarContratoVincular"
                    placeholder="Ingrese número de contrato"
                    :disabled="!contratoPrincipal"
                  />
                  <button
                    class="btn-municipal-primary"
                    @click="buscarContratoVincular"
                    :disabled="cargando || !contratoPrincipal"
                  >
                    <font-awesome-icon icon="search" />
                  </button>
                </div>
              </div>

              <div v-if="contratoVincular" class="municipal-alert municipal-alert-info">
                <h6 class="alert-heading">
                  <font-awesome-icon icon="check-circle" class="me-2" />
                  Contrato a Vincular
                </h6>
                <p class="mb-1"><strong>Contrato:</strong> {{ contratoVincular.num_contrato }}</p>
                <p class="mb-1"><strong>Contribuyente:</strong> {{ contratoVincular.contribuyente }}</p>
                <p class="mb-1"><strong>Domicilio:</strong> {{ contratoVincular.domicilio }}</p>
                <p class="mb-0"><strong>Tipo:</strong> {{ formatTipoAseo(contratoVincular.tipo_aseo) }}</p>
              </div>

              <div v-if="contratoPrincipal && contratoVincular" class="mt-3">
                <div class="form-group">
                  <label class="municipal-form-label">Tipo de Relación <span class="text-danger">*</span></label>
                  <select class="municipal-form-control" v-model="datosVinculacion.tipo_relacion">
                    <option value="">Seleccione...</option>
                    <option value="MISMO_PROPIETARIO">Mismo Propietario</option>
                    <option value="MISMO_DOMICILIO">Mismo Domicilio</option>
                    <option value="SUCURSAL">Sucursal</option>
                    <option value="MATRIZ">Matriz/Filial</option>
                    <option value="SUSTITUTO">Sustituto</option>
                    <option value="FRACCIONAMIENTO">Fraccionamiento</option>
                    <option value="OTRO">Otro</option>
                  </select>
                </div>

                <div class="form-group">
                  <label class="municipal-form-label">Observaciones</label>
                  <textarea
                    class="municipal-form-control"
                    v-model="datosVinculacion.observaciones"
                    rows="2"
                    placeholder="Motivo o detalles de la vinculación..."
                  ></textarea>
                </div>

                <div class="form-check mb-3">
                  <input
                    class="form-check-input"
                    type="checkbox"
                    v-model="datosVinculacion.bidireccional"
                    id="bidireccional"
                  />
                  <label class="form-check-label" for="bidireccional">
                    Vincular en ambos sentidos
                  </label>
                  <small class="form-text text-muted d-block">
                    La relación se creará desde ambos contratos
                  </small>
                </div>

                <div class="form-check mb-3">
                  <input
                    class="form-check-input"
                    type="checkbox"
                    v-model="datosVinculacion.compartir_saldo"
                    id="compartirSaldo"
                  />
                  <label class="form-check-label" for="compartirSaldo">
                    Compartir información de saldos
                  </label>
                  <small class="form-text text-muted d-block">
                    Los adeudos de ambos contratos se mostrarán juntos
                  </small>
                </div>

                <button
                  class="btn-municipal-primary w-100"
                  @click="vincularContratos"
                  :disabled="!datosVinculacion.tipo_relacion || vinculando"
                >
                  <font-awesome-icon icon="link" class="me-1" />
                  <span v-if="!vinculando">Vincular Contratos</span>
                  <span v-else>
                    <span class="spinner-border spinner-border-sm me-1"></span>
                    Vinculando...
                  </span>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Tab: Grupos de Contratos -->
    <div v-if="tabActual === 'grupos'">
      <div class="row">
        <!-- Lista de Grupos -->
        <div class="col-md-4">
          <div class="municipal-card">
            <div class="municipal-card-header">
        <h5>Grupos Existentes</h5>
            </div>
            <div class="municipal-card-body">
              <div v-if="grupos.length > 0" style="max-height: 500px; overflow-y: auto;">
                <div
                  v-for="grupo in grupos"
                  :key="grupo.id"
                  class="grupo-item p-3 mb-2 border rounded"
                  :class="{ 'border-primary bg-light': grupoSeleccionado?.id === grupo.id }"
                  @click="seleccionarGrupo(grupo)"
                  style="cursor: pointer;"
                >
                  <div class="d-flex justify-content-between align-items-start">
                    <div>
                      <h6 class="mb-1">{{ grupo.nombre_grupo }}</h6>
                      <p class="mb-1 text-muted small">{{ grupo.descripcion }}</p>
                      <div class="mt-2">
                        <span class="badge badge-info">{{ grupo.num_contratos }} contratos</span>
                        <span class="badge bg-success ms-1" v-if="grupo.activo">Activo</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div v-else class="alert alert-info mb-0">
                <font-awesome-icon icon="info-circle" class="me-2" />
                No hay grupos registrados
              </div>

              <button class="btn-municipal-primary w-100 mt-3" @click="nuevoGrupo">
                <font-awesome-icon icon="plus" class="me-1" />
                Nuevo Grupo
              </button>
            </div>
          </div>
        </div>

        <!-- Detalles del Grupo -->
        <div class="col-md-8">
          <div class="municipal-card">
            <div class="municipal-card-header">
        <h5>
                {{ modoEdicionGrupo ? grupoSeleccionado?.nombre_grupo : 'Nuevo Grupo' }}
              </h5>
            </div>
            <div class="municipal-card-body">
              <div class="form-group">
                <label class="municipal-form-label">Nombre del Grupo <span class="text-danger">*</span></label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="formGrupo.nombre_grupo"
                  placeholder="Ej: Grupo Empresarial ABC"
                />
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Descripción</label>
                <textarea
                  class="municipal-form-control"
                  v-model="formGrupo.descripcion"
                  rows="2"
                  placeholder="Descripción del grupo..."
                ></textarea>
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Tipo de Agrupación</label>
                <select class="municipal-form-control" v-model="formGrupo.tipo_agrupacion">
                  <option value="PROPIETARIO">Por Propietario</option>
                  <option value="ZONA">Por Zona Geográfica</option>
                  <option value="EMPRESA">Por Empresa</option>
                  <option value="FRACCIONAMIENTO">Por Fraccionamiento</option>
                  <option value="OTRO">Otro</option>
                </select>
              </div>

              <div class="form-check mb-3">
                <input
                  class="form-check-input"
                  type="checkbox"
                  v-model="formGrupo.activo"
                  id="grupoActivo"
                />
                <label class="form-check-label" for="grupoActivo">
                  Grupo activo
                </label>
              </div>

              <div class="form-check mb-3">
                <input
                  class="form-check-input"
                  type="checkbox"
                  v-model="formGrupo.facturacion_consolidada"
                  id="facturacionConsolidada"
                />
                <label class="form-check-label" for="facturacionConsolidada">
                  Facturación consolidada
                </label>
                <small class="form-text text-muted d-block">
                  Todos los contratos del grupo se facturan en un solo documento
                </small>
              </div>

              <!-- Contratos del Grupo -->
              <div v-if="modoEdicionGrupo && contratosGrupo.length > 0" class="mb-3">
                <h6>Contratos en el Grupo ({{ contratosGrupo.length }})</h6>
                <div class="table-responsive">
                  <table class="municipal-table">
                    <thead class="municipal-table-header">
                      <tr>
                        <th>Contrato</th>
                        <th>Contribuyente</th>
                        <th>Domicilio</th>
                        <th>Acciones</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-for="contrato in contratosGrupo" :key="contrato.num_contrato">
                        <td>{{ contrato.num_contrato }}</td>
                        <td>{{ contrato.contribuyente }}</td>
                        <td>{{ contrato.domicilio }}</td>
                        <td>
                          <button
                            class="btn btn-sm btn-danger"
                            @click="quitarContratoGrupo(contrato)"
                            title="Quitar del grupo"
                          >
                            <font-awesome-icon icon="times" />
                          </button>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>

                <!-- Agregar Contrato al Grupo -->
                <div class="municipal-card border-success mt-3">
                  <div class="municipal-card-body">
                    <h6 class="mb-3">Agregar Contrato al Grupo</h6>
                    <div class="input-group">
                      <input
                        type="text"
                        class="municipal-form-control"
                        v-model="contratoAgregar"
                        placeholder="Número de contrato"
                        @keyup.enter="agregarContratoGrupo"
                      />
                      <button class="btn-municipal-primary" @click="agregarContratoGrupo">
                        <font-awesome-icon icon="plus" class="me-1" />
                        Agregar
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              <div class="d-flex gap-2">
                <button
                  class="btn-municipal-primary"
                  @click="guardarGrupo"
                  :disabled="!formGrupo.nombre_grupo || guardando"
                >
                  <font-awesome-icon icon="save" class="me-1" />
                  <span v-if="!guardando">{{ modoEdicionGrupo ? 'Actualizar' : 'Crear Grupo' }}</span>
                  <span v-else>
                    <span class="spinner-border spinner-border-sm me-1"></span>
                    Guardando...
                  </span>
                </button>
                <button class="btn-municipal-secondary" @click="cancelarEdicionGrupo" v-if="modoEdicionGrupo">
                  <font-awesome-icon icon="times" class="me-1" />
                  Cancelar
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Tab: Consulta de Relaciones -->
    <div v-if="tabActual === 'consulta'">
      <div class="municipal-card">
        <div class="municipal-card-header">
        <h5>Consulta de Relaciones entre Contratos</h5>
        </div>
        <div class="municipal-card-body">
          <!-- Filtros de búsqueda -->
          <div class="row mb-3">
            <div class="col-md-4">
              <div class="form-group">
                <label class="municipal-form-label">Número de Contrato</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="filtrosConsulta.num_contrato"
                  placeholder="Buscar por contrato..."
                />
              </div>
            </div>
            <div class="col-md-3">
              <div class="form-group">
                <label class="municipal-form-label">Tipo de Relación</label>
                <select class="municipal-form-control" v-model="filtrosConsulta.tipo_relacion">
                  <option value="">Todas</option>
                  <option value="MISMO_PROPIETARIO">Mismo Propietario</option>
                  <option value="MISMO_DOMICILIO">Mismo Domicilio</option>
                  <option value="SUCURSAL">Sucursal</option>
                  <option value="MATRIZ">Matriz/Filial</option>
                  <option value="SUSTITUTO">Sustituto</option>
                  <option value="FRACCIONAMIENTO">Fraccionamiento</option>
                  <option value="OTRO">Otro</option>
                </select>
              </div>
            </div>
            <div class="col-md-3">
              <div class="form-group">
                <label class="municipal-form-label">Grupo</label>
                <select class="municipal-form-control" v-model="filtrosConsulta.grupo_id">
                  <option value="">Todos</option>
                  <option v-for="grupo in grupos" :key="grupo.id" :value="grupo.id">
                    {{ grupo.nombre_grupo }}
                  </option>
                </select>
              </div>
            </div>
            <div class="col-md-2">
              <label class="municipal-form-label">&nbsp;</label>
              <button class="btn-municipal-primary w-100" @click="consultarRelaciones" :disabled="cargando">
                <font-awesome-icon icon="search" class="me-1" />
                Consultar
              </button>
            </div>
          </div>

          <!-- Resultados -->
          <div v-if="relacionesEncontradas.length > 0">
            <div class="table-responsive">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr>
                    <th>Contrato Principal</th>
                    <th>Contribuyente</th>
                    <th>Contrato Relacionado</th>
                    <th>Tipo Relación</th>
                    <th>Bidireccional</th>
                    <th>Grupo</th>
                    <th>Fecha</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="rel in relacionesFiltradas" :key="`${rel.num_contrato_principal}-${rel.num_contrato_relacionado}`">
                    <td><strong>{{ rel.num_contrato_principal }}</strong></td>
                    <td>{{ rel.contribuyente }}</td>
                    <td>{{ rel.num_contrato_relacionado }}</td>
                    <td>
                      <span class="badge badge-info">{{ formatTipoRelacion(rel.tipo_relacion) }}</span>
                    </td>
                    <td>
                      <span v-if="rel.bidireccional" class="badge badge-success">Sí</span>
                      <span v-else class="badge badge-secondary">No</span>
                    </td>
                    <td>{{ rel.nombre_grupo || 'N/A' }}</td>
                    <td>{{ formatFecha(rel.fecha_vinculacion) }}</td>
                  </tr>
                </tbody>
              </table>
            </div>

            <div class="alert alert-info mt-3">
              <strong>Total de relaciones encontradas:</strong> {{ relacionesEncontradas.length }}
            </div>
          </div>

          <div v-else-if="!cargando" class="municipal-alert municipal-alert-warning">
            <font-awesome-icon icon="info-circle" class="me-2" />
            No se encontraron relaciones con los criterios especificados.
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->

    <DocumentationModal
      v-if="mostrarAyuda"
      :show="mostrarAyuda"
      @close="mostrarAyuda = false"
      title="Relación entre Contratos - Ayuda"
    >
      <h6>Descripción</h6>
      <p>
        Este módulo permite establecer relaciones entre contratos de aseo contratado y organizarlos
        en grupos para facilitar su gestión y facturación.
      </p>

      <h6>Tipos de Relación</h6>
      <ul>
        <li><strong>Mismo Propietario:</strong> Contratos pertenecientes al mismo contribuyente</li>
        <li><strong>Mismo Domicilio:</strong> Contratos ubicados en el mismo domicilio</li>
        <li><strong>Sucursal:</strong> Relación entre matriz y sucursales</li>
        <li><strong>Sustituto:</strong> Contrato que sustituye a otro</li>
        <li><strong>Fraccionamiento:</strong> Contratos dentro de un mismo fraccionamiento</li>
      </ul>

      <h6>Grupos de Contratos</h6>
      <p>
        Los grupos permiten agrupar múltiples contratos relacionados para:
      </p>
      <ul>
        <li>Facturación consolidada</li>
        <li>Consulta de saldos agrupados</li>
        <li>Reportes por grupo</li>
        <li>Gestión centralizada</li>
      </ul>

      <h6>Consideraciones</h6>
      <ul>
        <li>Las relaciones bidireccionales se crean en ambos sentidos</li>
        <li>Un contrato puede pertenecer a un solo grupo</li>
        <li>Las relaciones pueden compartir información de saldos</li>
        <li>Los grupos pueden tener facturación consolidada</li>
      </ul>
    </DocumentationModal>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'RelacionContratos'"
      :moduleName="'aseo_contratado'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref, computed, onMounted } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import Swal from 'sweetalert2'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useToast } from '@/composables/useToast'

const { showLoading, hideLoading } = useGlobalLoading()

const { execute } = useApi()
const { handleApiError } = useLicenciasErrorHandler()
const { showToast } = useToast()

// Estado
const tabActual = ref('vincular')
const cargando = ref(false)
const vinculando = ref(false)
const guardando = ref(false)
const mostrarAyuda = ref(false)
const modoEdicionGrupo = ref(false)

// Vinculación
const busqueda = ref({
  contrato_principal: '',
  contrato_vincular: ''
})
const contratoPrincipal = ref(null)
const contratoVincular = ref(null)
const contratosRelacionados = ref([])
const datosVinculacion = ref({
  tipo_relacion: '',
  observaciones: '',
  bidireccional: true,
  compartir_saldo: false
})

// Grupos
const grupos = ref([])
const grupoSeleccionado = ref(null)
const contratosGrupo = ref([])
const contratoAgregar = ref('')
const formGrupo = ref({
  nombre_grupo: '',
  descripcion: '',
  tipo_agrupacion: 'PROPIETARIO',
  activo: true,
  facturacion_consolidada: false
})

// Consulta
const filtrosConsulta = ref({
  num_contrato: '',
  tipo_relacion: '',
  grupo_id: ''
})
const relacionesEncontradas = ref([])

// Computed
const relacionesFiltradas = computed(() => {
  let resultado = [...relacionesEncontradas.value]

  if (filtrosConsulta.value.num_contrato) {
    const busq = filtrosConsulta.value.num_contrato.toLowerCase()
    resultado = resultado.filter(r =>
      r.num_contrato_principal.toLowerCase().includes(busq) ||
      r.num_contrato_relacionado.toLowerCase().includes(busq)
    )
  }

  return resultado
})

// Métodos - Vinculación
const buscarContratoPrincipal = async () => {
  if (!busqueda.value.contrato_principal) {
    showToast('Ingrese un número de contrato', 'warning')
    return
  }

  cargando.value = true
  try {
    const response = await execute('SP_ASEO_CONTRATO_CONSULTAR', 'aseo_contratado', {
      p_num_contrato: busqueda.value.contrato_principal
    })

    if (response && response.length > 0) {
      contratoPrincipal.value = response[0]
      await cargarContratosRelacionados()
      showToast('Contrato encontrado', 'success')
    } else {
      showToast('Contrato no encontrado', 'error')
      contratoPrincipal.value = null
      contratosRelacionados.value = []
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al buscar contrato')
    contratoPrincipal.value = null
    contratosRelacionados.value = []
  } finally {
    cargando.value = false
  }
}

const cargarContratosRelacionados = async () => {
  if (!contratoPrincipal.value) return

  try {
    const response = await execute('SP_ASEO_RELACIONES_LISTAR', 'aseo_contratado', {
      p_control_contrato: contratoPrincipal.value.control_contrato
    })
    contratosRelacionados.value = response || []
  } catch (error) {
    hideLoading()
    handleApiError(error)
    contratosRelacionados.value = []
  }
}

const buscarContratoVincular = async () => {
  if (!busqueda.value.contrato_vincular) {
    showToast('Ingrese un número de contrato', 'warning')
    return
  }

  if (busqueda.value.contrato_vincular === busqueda.value.contrato_principal) {
    showToast('No puede vincular un contrato consigo mismo', 'error')
    return
  }

  cargando.value = true
  try {
    const response = await execute('SP_ASEO_CONTRATO_CONSULTAR', 'aseo_contratado', {
      p_num_contrato: busqueda.value.contrato_vincular
    })

    if (response && response.length > 0) {
      contratoVincular.value = response[0]
      showToast('Contrato encontrado', 'success')
    } else {
      showToast('Contrato no encontrado', 'error')
      contratoVincular.value = null
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al buscar contrato')
    contratoVincular.value = null
  } finally {
    cargando.value = false
  }
}

const vincularContratos = async () => {
  vinculando.value = true
  try {
    await execute('SP_ASEO_CONTRATOS_VINCULAR', 'aseo_contratado', {
      p_control_contrato_principal: contratoPrincipal.value.control_contrato,
      p_control_contrato_vincular: contratoVincular.value.control_contrato,
      p_tipo_relacion: datosVinculacion.value.tipo_relacion,
      p_observaciones: datosVinculacion.value.observaciones,
      p_bidireccional: datosVinculacion.value.bidireccional ? 'S' : 'N',
      p_compartir_saldo: datosVinculacion.value.compartir_saldo ? 'S' : 'N'
    })

    showToast('Contratos vinculados exitosamente', 'success')

    // Limpiar y recargar
    contratoVincular.value = null
    busqueda.value.contrato_vincular = ''
    datosVinculacion.value = {
      tipo_relacion: '',
      observaciones: '',
      bidireccional: true,
      compartir_saldo: false
    }
    await cargarContratosRelacionados()

  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al vincular contratos')
  } finally {
    vinculando.value = false
  }
}

const desvincularContrato = async (relacion) => {
  const result = await Swal.fire({
    title: '¿Desvincular Contrato?',
    html: `Se eliminará la relación con el contrato <strong>${relacion.num_contrato_relacionado}</strong>`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    confirmButtonText: 'Sí, Desvincular',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    try {
      await execute('SP_ASEO_CONTRATOS_DESVINCULAR', 'aseo_contratado', {
        p_id_relacion: relacion.id
      })

      showToast('Contrato desvinculado exitosamente', 'success')
      await cargarContratosRelacionados()
    } catch (error) {
      hideLoading()
      handleApiError(error, 'Error al desvincular contrato')
    }
  }
}

// Métodos - Grupos
const cargarGrupos = async () => {
  try {
    const response = await execute('SP_ASEO_GRUPOS_LISTAR', 'aseo_contratado', {})
    grupos.value = response || []
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al cargar grupos')
    grupos.value = []
  }
}

const seleccionarGrupo = async (grupo) => {
  grupoSeleccionado.value = grupo
  formGrupo.value = { ...grupo }
  modoEdicionGrupo.value = true

  // Cargar contratos del grupo
  try {
    const response = await execute('SP_ASEO_GRUPO_CONTRATOS_LISTAR', 'aseo_contratado', {
      p_grupo_id: grupo.id
    })
    contratosGrupo.value = response || []
  } catch (error) {
    hideLoading()
    handleApiError(error)
    contratosGrupo.value = []
  }
}

const nuevoGrupo = () => {
  grupoSeleccionado.value = null
  contratosGrupo.value = []
  formGrupo.value = {
    nombre_grupo: '',
    descripcion: '',
    tipo_agrupacion: 'PROPIETARIO',
    activo: true,
    facturacion_consolidada: false
  }
  modoEdicionGrupo.value = false
}

const guardarGrupo = async () => {
  guardando.value = true
  try {
    const sp = modoEdicionGrupo.value ? 'SP_ASEO_GRUPO_ACTUALIZAR' : 'SP_ASEO_GRUPO_INSERTAR'

    await execute(sp, 'aseo_contratado', {
      p_id: modoEdicionGrupo.value ? formGrupo.value.id : undefined,
      p_nombre_grupo: formGrupo.value.nombre_grupo,
      p_descripcion: formGrupo.value.descripcion,
      p_tipo_agrupacion: formGrupo.value.tipo_agrupacion,
      p_activo: formGrupo.value.activo ? 'S' : 'N',
      p_facturacion_consolidada: formGrupo.value.facturacion_consolidada ? 'S' : 'N'
    })

    showToast(
      modoEdicionGrupo.value ? 'Grupo actualizado exitosamente' : 'Grupo creado exitosamente',
      'success'
    )
    await cargarGrupos()
    nuevoGrupo()
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al guardar grupo')
  } finally {
    guardando.value = false
  }
}

const cancelarEdicionGrupo = () => {
  nuevoGrupo()
}

const agregarContratoGrupo = async () => {
  if (!contratoAgregar.value) {
    showToast('Ingrese un número de contrato', 'warning')
    return
  }

  try {
    await execute('SP_ASEO_GRUPO_AGREGAR_CONTRATO', 'aseo_contratado', {
      p_grupo_id: grupoSeleccionado.value.id,
      p_num_contrato: contratoAgregar.value
    })

    showToast('Contrato agregado al grupo', 'success')
    contratoAgregar.value = ''
    await seleccionarGrupo(grupoSeleccionado.value)
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al agregar contrato al grupo')
  }
}

const quitarContratoGrupo = async (contrato) => {
  const result = await Swal.fire({
    title: '¿Quitar Contrato del Grupo?',
    text: `Se quitará el contrato ${contrato.num_contrato} del grupo`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    confirmButtonText: 'Sí, Quitar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    try {
      await execute('SP_ASEO_GRUPO_QUITAR_CONTRATO', 'aseo_contratado', {
        p_grupo_id: grupoSeleccionado.value.id,
        p_num_contrato: contrato.num_contrato
      })

      showToast('Contrato quitado del grupo', 'success')
      await seleccionarGrupo(grupoSeleccionado.value)
    } catch (error) {
      hideLoading()
      handleApiError(error, 'Error al quitar contrato del grupo')
    }
  }
}

// Métodos - Consulta
const consultarRelaciones = async () => {
  cargando.value = true
  try {
    const response = await execute('SP_ASEO_RELACIONES_CONSULTAR', 'aseo_contratado', {
      p_tipo_relacion: filtrosConsulta.value.tipo_relacion || null,
      p_grupo_id: filtrosConsulta.value.grupo_id || null
    })

    relacionesEncontradas.value = response || []
    showToast(`${relacionesEncontradas.value.length} relación(es) encontrada(s)`, 'success')
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al consultar relaciones')
    relacionesEncontradas.value = []
  } finally {
    cargando.value = false
  }
}

// Formatters
const formatTipoAseo = (tipo) => {
  const tipos = {
    'D': 'Doméstico',
    'C': 'Comercial',
    'I': 'Industrial',
    'S': 'Servicios',
    'E': 'Especial'
  }
  return tipos[tipo] || tipo
}

const formatTipoRelacion = (tipo) => {
  const tipos = {
    'MISMO_PROPIETARIO': 'Mismo Propietario',
    'MISMO_DOMICILIO': 'Mismo Domicilio',
    'SUCURSAL': 'Sucursal',
    'MATRIZ': 'Matriz/Filial',
    'SUSTITUTO': 'Sustituto',
    'FRACCIONAMIENTO': 'Fraccionamiento',
    'OTRO': 'Otro'
  }
  return tipos[tipo] || tipo
}

const formatFecha = (fecha) => {
  if (!fecha) return 'N/A'
  return new Date(fecha).toLocaleDateString('es-MX')
}

// Inicialización
onMounted(() => {
  cargarGrupos()
})

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>

