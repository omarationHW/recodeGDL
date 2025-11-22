<template>
  <div class="container-fluid py-4">
    <div class="municipal-card" style="min-height: 350px;">
      <div class="municipal-card-header">
        <h5 class="mb-0">Consulta de Condonaciones</h5>
      </div>
      <div class="municipal-card-body">
        <!-- Filtros de búsqueda -->
        <div class="bg-light rounded p-3 mb-4" style="min-height: 150px;">
          <div class="row g-3">
            <div class="col-md-3">
              <label class="form-label">Recaudadora</label>
              <select v-model="filters.oficina" class="form-select form-select-sm" @change="onRecChange">
                <option value="">Seleccione</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>
            <div class="col-md-3">
              <label class="form-label">Mercado</label>
              <select v-model="filters.num_mercado" class="form-select form-select-sm">
                <option value="">Seleccione</option>
                <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
                  {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                </option>
              </select>
            </div>
            <div class="col-md-2">
              <label class="form-label">Categoría</label>
              <input v-model="filters.categoria" type="number" class="form-control form-control-sm" />
            </div>
            <div class="col-md-2">
              <label class="form-label">Sección</label>
              <input v-model="filters.seccion" type="text" class="form-control form-control-sm" maxlength="2" />
            </div>
            <div class="col-md-2">
              <label class="form-label">Local</label>
              <input v-model="filters.local" type="number" class="form-control form-control-sm" />
            </div>
          </div>
          <div class="row g-3 mt-2">
            <div class="col-md-2">
              <label class="form-label">Letra</label>
              <input v-model="filters.letra_local" type="text" class="form-control form-control-sm" maxlength="3" />
            </div>
            <div class="col-md-2">
              <label class="form-label">Bloque</label>
              <input v-model="filters.bloque" type="text" class="form-control form-control-sm" maxlength="2" />
            </div>
            <div class="col-md-8 d-flex align-items-end justify-content-end">
              <button class="btn btn-municipal-primary btn-sm me-2" @click="buscarLocal" :disabled="loading">
                <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
                Buscar
              </button>
              <button class="btn btn-outline-secondary btn-sm" @click="limpiar">Limpiar</button>
            </div>
          </div>
        </div>

        <!-- Datos del local encontrado -->
        <div v-if="localData" class="mb-4">
          <div class="alert alert-info">
            <strong>Local:</strong> {{ localData.nombre }} |
            <strong>Superficie:</strong> {{ localData.superficie }} m² |
            <strong>Clave Cuota:</strong> {{ localData.clave_cuota }}
          </div>
        </div>

        <!-- Adeudos pendientes -->
        <div v-if="localData" class="row">
          <div class="col-md-6">
            <h6>Adeudos Pendientes</h6>
            <div class="table-responsive" style="max-height: 300px; overflow-y: auto;">
              <table class="table table-sm table-striped municipal-table">
                <thead class="sticky-top bg-light">
                  <tr>
                    <th>Año</th>
                    <th>Mes</th>
                    <th>Importe</th>
                    <th>Acción</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="adeudo in adeudos" :key="`${adeudo.axo}-${adeudo.periodo}`">
                    <td>{{ adeudo.axo }}</td>
                    <td>{{ adeudo.periodo }}</td>
                    <td>{{ formatCurrency(adeudo.importe) }}</td>
                    <td>
                      <button class="btn btn-sm btn-warning" @click="abrirCondonar(adeudo)" title="Condonar">
                        <i class="bi bi-x-circle"></i>
                      </button>
                    </td>
                  </tr>
                  <tr v-if="!adeudos.length">
                    <td colspan="4" class="text-center text-muted">Sin adeudos pendientes</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <div class="col-md-6">
            <h6>Adeudos Condonados</h6>
            <div class="table-responsive" style="max-height: 300px; overflow-y: auto;">
              <table class="table table-sm table-striped municipal-table">
                <thead class="sticky-top bg-light">
                  <tr>
                    <th>Año</th>
                    <th>Mes</th>
                    <th>Importe</th>
                    <th>Acción</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="cond in condonados" :key="cond.id_cancelacion">
                    <td>{{ cond.axo }}</td>
                    <td>{{ cond.periodo }}</td>
                    <td>{{ formatCurrency(cond.importe) }}</td>
                    <td>
                      <button class="btn btn-sm btn-info" @click="deshacerCondonacion(cond)" title="Deshacer">
                        <i class="bi bi-arrow-counterclockwise"></i>
                      </button>
                    </td>
                  </tr>
                  <tr v-if="!condonados.length">
                    <td colspan="4" class="text-center text-muted">Sin condonaciones</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <!-- Modal Condonar -->
        <div v-if="showModal" class="modal fade show d-block" tabindex="-1">
          <div class="modal-dialog">
            <div class="modal-content">
              <div class="modal-header">
                <h5 class="modal-title">Condonar Adeudo</h5>
                <button type="button" class="btn-close" @click="showModal = false"></button>
              </div>
              <div class="modal-body">
                <p><strong>Año:</strong> {{ selectedAdeudo?.axo }} | <strong>Mes:</strong> {{ selectedAdeudo?.periodo }}</p>
                <p><strong>Importe:</strong> {{ formatCurrency(selectedAdeudo?.importe) }}</p>
                <div class="mb-3">
                  <label class="form-label">Clave Cancelación</label>
                  <input v-model="formCondonar.clave_canc" type="text" class="form-control" maxlength="10" />
                </div>
                <div class="mb-3">
                  <label class="form-label">Observación</label>
                  <textarea v-model="formCondonar.observacion" class="form-control" rows="3"></textarea>
                </div>
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-secondary" @click="showModal = false">Cancelar</button>
                <button type="button" class="btn btn-warning" @click="condonar" :disabled="loading">
                  <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
                  Condonar
                </button>
              </div>
            </div>
          </div>
        </div>
        <div v-if="showModal" class="modal-backdrop fade show"></div>

        <!-- Modal de Mensajes -->
        <div v-if="showMessageModal" class="modal fade show d-block" tabindex="-1">
          <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
              <div class="modal-header" :class="messageModal.headerClass">
                <h5 class="modal-title">{{ messageModal.title }}</h5>
                <button type="button" class="btn-close" @click="showMessageModal = false"></button>
              </div>
              <div class="modal-body">
                <p class="mb-0">{{ messageModal.message }}</p>
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-secondary" @click="showMessageModal = false">Cerrar</button>
              </div>
            </div>
          </div>
        </div>
        <div v-if="showMessageModal" class="modal-backdrop fade show"></div>

        <!-- Modal de Confirmación -->
        <div v-if="showConfirmModal" class="modal fade show d-block" tabindex="-1">
          <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
              <div class="modal-header bg-warning text-dark">
                <h5 class="modal-title">Confirmar</h5>
                <button type="button" class="btn-close" @click="showConfirmModal = false"></button>
              </div>
              <div class="modal-body">
                <p class="mb-0">{{ confirmMessage }}</p>
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-secondary" @click="showConfirmModal = false">Cancelar</button>
                <button type="button" class="btn btn-warning" @click="ejecutarConfirm">Aceptar</button>
              </div>
            </div>
          </div>
        </div>
        <div v-if="showConfirmModal" class="modal-backdrop fade show"></div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';

const loading = ref(false);
const recaudadoras = ref([]);
const mercados = ref([]);
const localData = ref(null);
const adeudos = ref([]);
const condonados = ref([]);
const selectedAdeudo = ref(null);
const showModal = ref(false);

// Modal de mensajes
const showMessageModal = ref(false);
const messageModal = ref({
  title: '',
  message: '',
  headerClass: ''
});

// Modal de confirmación
const showConfirmModal = ref(false);
const confirmMessage = ref('');
const confirmCallback = ref(null);

const mostrarMensaje = (mensaje, tipo = 'info') => {
  const config = {
    success: { title: 'Éxito', headerClass: 'bg-success text-white' },
    error: { title: 'Error', headerClass: 'bg-danger text-white' },
    warning: { title: 'Advertencia', headerClass: 'bg-warning text-dark' },
    info: { title: 'Información', headerClass: 'bg-info text-white' }
  };
  messageModal.value = {
    title: config[tipo].title,
    message: mensaje,
    headerClass: config[tipo].headerClass
  };
  showMessageModal.value = true;
};

const mostrarConfirm = (mensaje, callback) => {
  confirmMessage.value = mensaje;
  confirmCallback.value = callback;
  showConfirmModal.value = true;
};

const ejecutarConfirm = () => {
  showConfirmModal.value = false;
  if (confirmCallback.value) {
    confirmCallback.value();
  }
};

const filters = ref({
  oficina: '',
  num_mercado: '',
  categoria: '',
  seccion: '',
  local: '',
  letra_local: '',
  bloque: ''
});

const formCondonar = ref({
  clave_canc: '',
  observacion: ''
});

const formatCurrency = (value) => {
  if (!value) return '$0.00';
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value);
};

const fetchRecaudadoras = async () => {
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_recaudadoras',
        Base: 'padron_licencias',
        Parametros: []
      }
    });
    if (response.data.eResponse?.success) {
      recaudadoras.value = response.data.eResponse.data.result || [];
    }
  } catch (error) {
    console.error('Error al cargar recaudadoras:', error);
  }
};

const onRecChange = async () => {
  mercados.value = [];
  filters.value.num_mercado = '';
  if (!filters.value.oficina) return;

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_consulta_locales_get_mercados',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_oficina', Valor: parseInt(filters.value.oficina) }
        ]
      }
    });
    if (response.data.eResponse?.success) {
      mercados.value = response.data.eResponse.data.result || [];
    }
  } catch (error) {
    console.error('Error al cargar mercados:', error);
  }
};

const buscarLocal = async () => {
  if (!filters.value.oficina || !filters.value.num_mercado || !filters.value.local) {
    mostrarMensaje('Complete los campos requeridos: Recaudadora, Mercado y Local', 'warning');
    return;
  }

  loading.value = true;
  localData.value = null;
  adeudos.value = [];
  condonados.value = [];

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_cons_condonacion_buscar_local',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_oficina', Valor: parseInt(filters.value.oficina) },
          { Nombre: 'p_num_mercado', Valor: parseInt(filters.value.num_mercado) },
          { Nombre: 'p_categoria', Valor: parseInt(filters.value.categoria) || 1 },
          { Nombre: 'p_seccion', Valor: filters.value.seccion || '' },
          { Nombre: 'p_local', Valor: parseInt(filters.value.local) },
          { Nombre: 'p_letra_local', Valor: filters.value.letra_local || null },
          { Nombre: 'p_bloque', Valor: filters.value.bloque || null }
        ]
      }
    });

    if (response.data.eResponse?.success) {
      const result = response.data.eResponse.data.result || [];
      if (result.length > 0) {
        localData.value = result[0];
        await cargarAdeudos();
        await cargarCondonados();
      } else {
        mostrarMensaje('Local no encontrado o no está vigente', 'warning');
      }
    }
  } catch (error) {
    console.error('Error al buscar local:', error);
    mostrarMensaje('Error al buscar local', 'error');
  } finally {
    loading.value = false;
  }
};

const cargarAdeudos = async () => {
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_cons_condonacion_listar_adeudos',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_id_local', Valor: localData.value.id_local }
        ]
      }
    });
    if (response.data.eResponse?.success) {
      adeudos.value = response.data.eResponse.data.result || [];
    }
  } catch (error) {
    console.error('Error al cargar adeudos:', error);
  }
};

const cargarCondonados = async () => {
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_cons_condonacion_listar_condonados',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_id_local', Valor: localData.value.id_local }
        ]
      }
    });
    if (response.data.eResponse?.success) {
      condonados.value = response.data.eResponse.data.result || [];
    }
  } catch (error) {
    console.error('Error al cargar condonados:', error);
  }
};

const abrirCondonar = (adeudo) => {
  selectedAdeudo.value = adeudo;
  formCondonar.value = { clave_canc: '', observacion: '' };
  showModal.value = true;
};

const condonar = async () => {
  if (!formCondonar.value.clave_canc) {
    mostrarMensaje('Ingrese la clave de cancelación', 'warning');
    return;
  }

  loading.value = true;
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_cons_condonacion_condonar',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_id_local', Valor: localData.value.id_local },
          { Nombre: 'p_axo', Valor: selectedAdeudo.value.axo },
          { Nombre: 'p_periodo', Valor: selectedAdeudo.value.periodo },
          { Nombre: 'p_importe', Valor: selectedAdeudo.value.importe },
          { Nombre: 'p_clave_canc', Valor: formCondonar.value.clave_canc },
          { Nombre: 'p_observacion', Valor: formCondonar.value.observacion || '' },
          { Nombre: 'p_id_usuario', Valor: 1 }
        ]
      }
    });

    if (response.data.eResponse?.success) {
      const result = response.data.eResponse.data.result?.[0];
      if (result?.success) {
        showModal.value = false;
        await cargarAdeudos();
        await cargarCondonados();
        mostrarMensaje('Adeudo condonado correctamente', 'success');
      } else {
        mostrarMensaje(result?.message || 'Error al condonar', 'error');
      }
    }
  } catch (error) {
    console.error('Error al condonar:', error);
    mostrarMensaje('Error al condonar adeudo', 'error');
  } finally {
    loading.value = false;
  }
};

const deshacerCondonacion = (cond) => {
  mostrarConfirm('¿Está seguro de deshacer esta condonación?', async () => {
    loading.value = true;
    try {
      const response = await axios.post('/api/generic', {
        eRequest: {
          Operacion: 'sp_cons_condonacion_deshacer',
          Base: 'padron_licencias',
          Parametros: [
            { Nombre: 'p_id_local', Valor: localData.value.id_local },
            { Nombre: 'p_axo', Valor: cond.axo },
            { Nombre: 'p_periodo', Valor: cond.periodo },
            { Nombre: 'p_importe', Valor: cond.importe },
            { Nombre: 'p_id_usuario', Valor: 1 },
            { Nombre: 'p_id_cancelacion', Valor: cond.id_cancelacion }
          ]
        }
      });

      if (response.data.eResponse?.success) {
        const result = response.data.eResponse.data.result?.[0];
        if (result?.success) {
          await cargarAdeudos();
          await cargarCondonados();
          mostrarMensaje('Condonación deshecha correctamente', 'success');
        } else {
          mostrarMensaje(result?.message || 'Error al deshacer', 'error');
        }
      }
    } catch (error) {
      console.error('Error al deshacer condonación:', error);
      mostrarMensaje('Error al deshacer condonación', 'error');
    } finally {
      loading.value = false;
    }
  });
};

const limpiar = () => {
  filters.value = {
    oficina: '',
    num_mercado: '',
    categoria: '',
    seccion: '',
    local: '',
    letra_local: '',
    bloque: ''
  };
  localData.value = null;
  adeudos.value = [];
  condonados.value = [];
  mercados.value = [];
};

onMounted(() => {
  fetchRecaudadoras();
});
</script>
