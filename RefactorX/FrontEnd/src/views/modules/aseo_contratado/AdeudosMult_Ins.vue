<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="layer-group" />
      </div>
      <div class="module-view-info">
        <h1>Inserción Masiva de Adeudos</h1>
        <p>Aseo Contratado - Insertar adeudos a múltiples contratos simultáneamente</p>
      </div>
      <button type="button" class="btn-help-icon" @click="openDocumentation" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <!-- Paso 1: Selección de Contratos -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="list-check" /> Paso 1: Selección de Contratos</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Tipo de Aseo</label>
              <select v-model="filtros.tipo_aseo" class="municipal-form-control" @change="cargarContratos">
                <option value="">Todos</option>
                <option value="C">Comercial</option>
                <option value="R">Residencial</option>
                <option value="I">Industrial</option>
                <option value="M">Mixto</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Status Contrato</label>
              <select v-model="filtros.status_contrato" class="municipal-form-control" @change="cargarContratos">
                <option value="N">Solo Activos</option>
                <option value="B">Solo Inactivos</option>
                <option value="">Todos</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Empresa</label>
              <select v-model="filtros.num_empresa" class="municipal-form-control" @change="cargarContratos">
                <option value="">Todas</option>
                <option v-for="emp in empresas" :key="emp.num_empresa" :value="emp.num_empresa">
                  {{ emp.descripcion }}
                </option>
              </select>
            </div>
          </div>

          <div class="button-group">
            <button class="btn-municipal-primary" @click="cargarContratos" :disabled="loadingContratos">
              <font-awesome-icon :icon="loadingContratos ? 'spinner' : 'search'" :spin="loadingContratos" /> Buscar Contratos
            </button>
            <button class="btn-municipal-secondary" @click="seleccionarTodos">
              <font-awesome-icon icon="check-double" /> Seleccionar Todos
            </button>
            <button class="btn-municipal-secondary" @click="deseleccionarTodos">
              <font-awesome-icon icon="times" /> Deseleccionar Todos
            </button>
          </div>

          <div v-if="contratos.length > 0" class="mt-3">
            <p class="text-muted">
              <font-awesome-icon icon="info-circle" />
              {{ contratosSeleccionados.length }} de {{ contratos.length }} contratos seleccionados
            </p>
            <div class="table-responsive" style="max-height: 300px; overflow-y: auto;">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr>
                    <th style="width: 50px;">
                      <input type="checkbox" @change="toggleTodos" :checked="todosMarcados" />
                    </th>
                    <th>Contrato</th>
                    <th>Empresa</th>
                    <th>Tipo Aseo</th>
                    <th class="text-center">Status</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="contrato in contratos" :key="contrato.control_contrato">
                    <td>
                      <input
                        type="checkbox"
                        :value="contrato.control_contrato"
                        v-model="contratosSeleccionados"
                      />
                    </td>
                    <td><strong>{{ contrato.num_contrato }}</strong></td>
                    <td>{{ contrato.empresa }}</td>
                    <td>{{ formatTipoAseo(contrato.tipo_aseo) }}</td>
                    <td class="text-center">
                      <span class="badge" :class="contrato.status_contrato === 'N' ? 'badge-success' : 'badge-danger'">
                        {{ contrato.status_contrato === 'N' ? 'ACTIVO' : 'INACTIVO' }}
                      </span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

      <!-- Paso 2: Parámetros del Adeudo -->
      <div class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="cog" /> Paso 2: Parámetros del Adeudo</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Periodo (Año-Mes)</label>
              <input type="month" v-model="parametrosAdeudo.periodo" class="municipal-form-control" required />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Clave de Operación</label>
              <select v-model="parametrosAdeudo.cve_operacion" class="municipal-form-control" required>
                <option value="">Seleccione...</option>
                <option v-for="op in clavesOperacion" :key="op.cve_operacion" :value="op.cve_operacion">
                  {{ op.cve_operacion }} - {{ op.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Cuota Base</label>
              <input
                type="number"
                v-model.number="parametrosAdeudo.cuota_base"
                class="municipal-form-control"
                step="0.01"
                min="0"
                required
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Aplicar Recargos</label>
              <select v-model="parametrosAdeudo.aplicar_recargos" class="municipal-form-control">
                <option value="S">Sí</option>
                <option value="N">No</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Aplicar Gastos de Cobranza</label>
              <select v-model="parametrosAdeudo.aplicar_gastos" class="municipal-form-control">
                <option value="S">Sí</option>
                <option value="N">No</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Observaciones</label>
              <input
                type="text"
                v-model="parametrosAdeudo.observaciones"
                class="municipal-form-control"
                placeholder="Observaciones del adeudo"
              />
            </div>
          </div>
        </div>
      </div>

      <!-- Paso 3: Vista Previa y Confirmación -->
      <div v-if="contratosSeleccionados.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="eye" /> Paso 3: Vista Previa</h5>
        </div>
        <div class="municipal-card-body">
          <div class="alert alert-info">
            <font-awesome-icon icon="info-circle" />
            Se insertarán <strong>{{ contratosSeleccionados.length }}</strong> adeudos para el periodo
            <strong>{{ formatPeriodo(parametrosAdeudo.periodo) }}</strong>
          </div>

          <div class="summary-grid mt-3">
            <div class="summary-card">
              <div class="summary-icon bg-primary"><font-awesome-icon icon="file-contract" /></div>
              <div class="summary-info">
                <p class="summary-label">Contratos Afectados</p>
                <p class="summary-value">{{ contratosSeleccionados.length }}</p>
              </div>
            </div>
            <div class="summary-card">
              <div class="summary-icon bg-warning"><font-awesome-icon icon="dollar-sign" /></div>
              <div class="summary-info">
                <p class="summary-label">Cuota Base por Contrato</p>
                <p class="summary-value">{{ formatCurrency(parametrosAdeudo.cuota_base) }}</p>
              </div>
            </div>
            <div class="summary-card highlight-money">
              <div class="summary-icon bg-success"><font-awesome-icon icon="calculator" /></div>
              <div class="summary-info">
                <p class="summary-label">Total a Generar</p>
                <p class="summary-value">{{ formatCurrency(parametrosAdeudo.cuota_base * contratosSeleccionados.length) }}</p>
              </div>
            </div>
          </div>

          <div class="button-group mt-3">
            <button
              class="btn-municipal-primary"
              @click="confirmarInsercion"
              :disabled="!validarFormulario() || loading"
            >
              <font-awesome-icon :icon="loading ? 'spinner' : 'check'" :spin="loading" />
              Confirmar e Insertar Adeudos
            </button>
            <button class="btn-municipal-secondary" @click="cancelar">
              <font-awesome-icon icon="times" /> Cancelar
            </button>
          </div>
        </div>
      </div>

      <!-- Resultados -->
      <div v-if="resultados.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="check-circle" /> Resultados de la Inserción</h5>
        </div>
        <div class="municipal-card-body">
          <div class="alert alert-success">
            <font-awesome-icon icon="check-circle" />
            Proceso completado: {{ resultados.filter(r => r.exito).length }} de {{ resultados.length }} adeudos insertados correctamente
          </div>

          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Contrato</th>
                  <th>Empresa</th>
                  <th class="text-center">Status</th>
                  <th>Mensaje</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(resultado, index) in resultados" :key="index">
                  <td><strong>{{ resultado.num_contrato }}</strong></td>
                  <td>{{ resultado.empresa }}</td>
                  <td class="text-center">
                    <span class="badge" :class="resultado.exito ? 'badge-success' : 'badge-danger'">
                      {{ resultado.exito ? 'ÉXITO' : 'ERROR' }}
                    </span>
                  </td>
                  <td>{{ resultado.mensaje }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <DocumentationModal :show="showDocumentation" @close="showDocumentation = false" title="Ayuda - Inserción Masiva">
      <h3>Inserción Masiva de Adeudos</h3>
      <p>Permite insertar adeudos a múltiples contratos simultáneamente con los mismos parámetros.</p>

      <h4>Proceso en 3 Pasos:</h4>
      <ol>
        <li>
          <strong>Selección de Contratos:</strong>
          <ul>
            <li>Filtrar contratos por tipo de aseo, status y empresa</li>
            <li>Seleccionar individual o masivamente los contratos</li>
            <li>Visualizar lista de contratos encontrados</li>
          </ul>
        </li>
        <li>
          <strong>Parámetros del Adeudo:</strong>
          <ul>
            <li>Periodo: Año y mes del adeudo (formato YYYY-MM)</li>
            <li>Clave de Operación: Tipo de movimiento</li>
            <li>Cuota Base: Monto del adeudo</li>
            <li>Opciones: Aplicar recargos y gastos de cobranza</li>
          </ul>
        </li>
        <li>
          <strong>Vista Previa y Confirmación:</strong>
          <ul>
            <li>Resumen de contratos afectados</li>
            <li>Cálculo de totales</li>
            <li>Confirmación final antes de insertar</li>
          </ul>
        </li>
      </ol>

      <h4>Campos Requeridos:</h4>
      <ul>
        <li>Al menos un contrato seleccionado</li>
        <li>Periodo válido</li>
        <li>Clave de operación</li>
        <li>Cuota base mayor a cero</li>
      </ul>

      <h4>Resultados:</h4>
      <p>Al finalizar, se muestra una tabla con el resultado de cada inserción, indicando éxito o error para cada contrato.</p>

      <h4>Recomendaciones:</h4>
      <ul>
        <li>Verificar que no existan adeudos duplicados para el mismo periodo</li>
        <li>Revisar la cuota base antes de confirmar</li>
        <li>Utilizar la vista previa para validar los datos</li>
      </ul>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import Swal from 'sweetalert2'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'

const { execute } = useApi()
const { showToast } = useLicenciasErrorHandler()

const loading = ref(false)
const loadingContratos = ref(false)
const showDocumentation = ref(false)
const contratos = ref([])
const empresas = ref([])
const clavesOperacion = ref([])
const contratosSeleccionados = ref([])
const resultados = ref([])

const filtros = ref({
  tipo_aseo: '',
  status_contrato: 'N',
  num_empresa: ''
})

const parametrosAdeudo = ref({
  periodo: '',
  cve_operacion: '',
  cuota_base: 0,
  aplicar_recargos: 'S',
  aplicar_gastos: 'N',
  observaciones: ''
})

const todosMarcados = computed(() => {
  return contratos.value.length > 0 && contratosSeleccionados.value.length === contratos.value.length
})

const cargarContratos = async () => {
  loadingContratos.value = true
  try {
    const parVigencia = filtros.value.status_contrato === 'N' ? 'V' :
                        filtros.value.status_contrato === 'B' ? 'B' : 'T'

    const response = await execute('sp16_contratos', 'aseo_contratado', {
      parTipo: filtros.value.tipo_aseo || 'T',
      parVigencia: parVigencia
    })

    let lista = response && response.data ? response.data : []

    // Filtrar por empresa si está seleccionada
    if (filtros.value.num_empresa) {
      lista = lista.filter(c => c.num_empresa === filtros.value.num_empresa)
    }

    contratos.value = lista
    contratosSeleccionados.value = []
    showToast(`${lista.length} contratos encontrados`, 'success')
  } catch (error) {
    showToast('Error al cargar contratos', 'error')
    console.error('Error:', error)
  } finally {
    loadingContratos.value = false
  }
}

const toggleTodos = () => {
  if (todosMarcados.value) {
    contratosSeleccionados.value = []
  } else {
    contratosSeleccionados.value = contratos.value.map(c => c.control_contrato)
  }
}

const seleccionarTodos = () => {
  contratosSeleccionados.value = contratos.value.map(c => c.control_contrato)
}

const deseleccionarTodos = () => {
  contratosSeleccionados.value = []
}

const validarFormulario = () => {
  return contratosSeleccionados.value.length > 0 &&
         parametrosAdeudo.value.periodo &&
         parametrosAdeudo.value.cve_operacion &&
         parametrosAdeudo.value.cuota_base > 0
}

const confirmarInsercion = async () => {
  const result = await Swal.fire({
    title: '¿Confirmar Inserción Masiva?',
    html: `
      <p>Se insertarán <strong>${contratosSeleccionados.value.length}</strong> adeudos.</p>
      <p><strong>Periodo:</strong> ${formatPeriodo(parametrosAdeudo.value.periodo)}</p>
      <p><strong>Cuota Base:</strong> ${formatCurrency(parametrosAdeudo.value.cuota_base)}</p>
      <p><strong>Total:</strong> ${formatCurrency(parametrosAdeudo.value.cuota_base * contratosSeleccionados.value.length)}</p>
      <p class="text-danger mt-2">Esta acción no se puede deshacer.</p>
    `,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, Insertar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#28a745',
    cancelButtonColor: '#dc3545'
  })

  if (result.isConfirmed) {
    await insertarAdeudos()
  }
}

const insertarAdeudos = async () => {
  loading.value = true
  resultados.value = []

  try {
    const periodo = parametrosAdeudo.value.periodo + '-01' // Convertir YYYY-MM a YYYY-MM-DD

    for (const controlContrato of contratosSeleccionados.value) {
      const contrato = contratos.value.find(c => c.control_contrato === controlContrato)

      try {
        // Llamar al SP de inserción individual
        await execute('SP_ASEO_ADEUDOS_INSERTAR', 'aseo_contratado', {
          p_control_contrato: controlContrato,
          p_periodo: periodo,
          p_cve_operacion: parametrosAdeudo.value.cve_operacion,
          p_cuota_base: parametrosAdeudo.value.cuota_base,
          p_recargos: parametrosAdeudo.value.aplicar_recargos === 'S' ? 0 : null,
          p_gastos_cobranza: parametrosAdeudo.value.aplicar_gastos === 'S' ? 0 : null,
          p_observaciones: parametrosAdeudo.value.observaciones,
          p_usuario_id: 1
        })

        resultados.value.push({
          num_contrato: contrato.num_contrato,
          empresa: contrato.empresa,
          exito: true,
          mensaje: 'Adeudo insertado correctamente'
        })
      } catch (error) {
        resultados.value.push({
          num_contrato: contrato.num_contrato,
          empresa: contrato.empresa,
          exito: false,
          mensaje: error.message || 'Error al insertar adeudo'
        })
      }
    }

    const exitosos = resultados.value.filter(r => r.exito).length
    showToast(`Proceso completado: ${exitosos} de ${resultados.value.length} adeudos insertados`, 'success')

    // Limpiar selección
    contratosSeleccionados.value = []
  } catch (error) {
    showToast('Error en el proceso de inserción', 'error')
    console.error('Error:', error)
  } finally {
    loading.value = false
  }
}

const cancelar = () => {
  contratosSeleccionados.value = []
  resultados.value = []
  parametrosAdeudo.value = {
    periodo: '',
    cve_operacion: '',
    cuota_base: 0,
    aplicar_recargos: 'S',
    aplicar_gastos: 'N',
    observaciones: ''
  }
}

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value || 0)
}

const formatPeriodo = (periodo) => {
  if (!periodo) return 'N/A'
  const [year, month] = periodo.split('-')
  const meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre']
  return `${meses[parseInt(month) - 1]} ${year}`
}

const formatTipoAseo = (tipo) => {
  const tipos = {
    'C': 'Comercial',
    'R': 'Residencial',
    'I': 'Industrial',
    'M': 'Mixto'
  }
  return tipos[tipo] || tipo
}

const openDocumentation = () => {
  showDocumentation.value = true
}

// Cargar datos iniciales
const cargarDatos = async () => {
  try {
    // Cargar empresas
    const responseEmpresas = await execute('SP_ASEO_EMPRESAS_LIST', 'aseo_contratado', {
      p_page: 1,
      p_limit: 1000,
      p_search: null
    })
    if (responseEmpresas && responseEmpresas.data) empresas.value = responseEmpresas.data

    // Cargar claves de operación
    const responseCves = await execute('SP_ASEO_CVES_OPERACION_LIST', 'aseo_contratado', {
      p_page: 1,
      p_limit: 100,
      p_search: null
    })
    if (responseCves && responseCves.data) clavesOperacion.value = responseCves.data
  } catch (error) {
    console.error('Error al cargar datos iniciales:', error)
  }
}

cargarDatos()
</script>

