<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="hand-holding-usd" />
      </div>
      <div class="module-view-info">
        <h1>Condonación de Adeudos</h1>
        <p>Mercados - Gestión de Condonaciones de Adeudos</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-danger" @click="cerrar">
          <font-awesome-icon icon="times" />
          Cerrar
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Búsqueda de Local -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Búsqueda de Local
          </h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="buscarLocal">
            <div class="row">
              <div class="col-md-3 mb-3">
                <label class="municipal-form-label">Recaudadora *</label>
                <select class="municipal-form-control" v-model="form.oficina" @change="onOficinaChange" required>
                  <option value="">Seleccione...</option>
                  <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                    {{ rec.id_rec }} - {{ rec.recaudadora }}
                  </option>
                </select>
              </div>
              <div class="col-md-3 mb-3">
                <label class="municipal-form-label">Mercado *</label>
                <select class="municipal-form-control" v-model="form.num_mercado" :disabled="!form.oficina" required>
                  <option value="">Seleccione...</option>
                  <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
                    {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                  </option>
                </select>
              </div>
              <div class="col-md-2 mb-3">
                <label class="municipal-form-label">Categoría *</label>
                <input type="number" class="municipal-form-control" v-model.number="form.categoria" required min="1" />
              </div>
              <div class="col-md-1 mb-3">
                <label class="municipal-form-label">Sección *</label>
                <input type="text" class="municipal-form-control" v-model="form.seccion" maxlength="2" required />
              </div>
              <div class="col-md-1 mb-3">
                <label class="municipal-form-label">Local *</label>
                <input type="number" class="municipal-form-control" v-model.number="form.local" required min="1" />
              </div>
              <div class="col-md-1 mb-3">
                <label class="municipal-form-label">Letra</label>
                <input type="text" class="municipal-form-control" v-model="form.letra_local" maxlength="1" />
              </div>
              <div class="col-md-1 mb-3">
                <label class="municipal-form-label">Bloque</label>
                <input type="text" class="municipal-form-control" v-model="form.bloque" maxlength="1" />
              </div>
            </div>
            <button type="submit" class="btn-municipal-primary" :disabled="loading">
              <font-awesome-icon icon="search" />
              Buscar
            </button>
          </form>

          <!-- Datos del Local -->
          <div v-if="localData" class="mt-3 p-3 bg-light rounded">
            <h6>Datos del Local</h6>
            <div class="row">
              <div class="col-md-6">
                <p><strong>Nombre:</strong> {{ localData.nombre }}</p>
                <p><strong>Descripción:</strong> {{ localData.descripcion_local }}</p>
              </div>
              <div class="col-md-6">
                <p><strong>Superficie:</strong> {{ localData.superficie }}</p>
                <p><strong>Clave Cuota:</strong> {{ localData.clave_cuota }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Adeudos a Condonar -->
      <div v-if="localData" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="file-invoice-dollar" />
            Adeudos a Condonar
            <span v-if="adeudos.length > 0" class="badge bg-warning ms-2">{{ adeudos.length }}</span>
          </h5>
          <button class="btn-municipal-primary btn-sm ms-auto" @click="listarAdeudos" :disabled="loading">
            <font-awesome-icon icon="sync" />
            Listar
          </button>
        </div>
        <div class="municipal-card-body">
          <div v-if="adeudos.length > 0" class="table-responsive">
            <table class="municipal-table">
              <thead>
                <tr>
                  <th style="width: 40px;"></th>
                  <th>Año</th>
                  <th>Mes</th>
                  <th>Importe</th>
                  <th>Detalle</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(a, idx) in adeudos" :key="idx">
                  <td><input type="checkbox" class="form-check-input" v-model="a.selected" /></td>
                  <td>{{ a.axo }}</td>
                  <td>{{ a.periodo }}</td>
                  <td>{{ formatCurrency(a.importe) }}</td>
                  <td>{{ a.detalle }}</td>
                </tr>
              </tbody>
            </table>
            <div class="mt-3">
              <div class="row align-items-end">
                <div class="col-md-4">
                  <label class="municipal-form-label">Oficio (LLL/9999/9999) *</label>
                  <input type="text" class="municipal-form-control" v-model="oficio" maxlength="13" placeholder="LLL/9999/9999" />
                </div>
                <div class="col-md-4">
                  <button class="btn-municipal-success" @click="condonarSeleccionados" :disabled="loading">
                    <font-awesome-icon icon="check" />
                    Condonar Seleccionados
                  </button>
                </div>
              </div>
            </div>
          </div>
          <div v-else class="text-center py-3 text-muted">
            <p>No hay adeudos pendientes</p>
          </div>
        </div>
      </div>

      <!-- Condonados -->
      <div v-if="localData" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="history" />
            Condonaciones Realizadas
            <span v-if="condonados.length > 0" class="badge bg-info ms-2">{{ condonados.length }}</span>
          </h5>
          <button class="btn-municipal-primary btn-sm ms-auto" @click="listarCondonados" :disabled="loading">
            <font-awesome-icon icon="sync" />
            Listar
          </button>
        </div>
        <div class="municipal-card-body">
          <div v-if="condonados.length > 0" class="table-responsive">
            <table class="municipal-table">
              <thead>
                <tr>
                  <th style="width: 40px;"></th>
                  <th>Año</th>
                  <th>Mes</th>
                  <th>Importe</th>
                  <th>Observación</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(c, idx) in condonados" :key="idx">
                  <td><input type="checkbox" class="form-check-input" v-model="c.selected" /></td>
                  <td>{{ c.axo }}</td>
                  <td>{{ c.periodo }}</td>
                  <td>{{ formatCurrency(c.importe) }}</td>
                  <td>{{ c.observacion }}</td>
                </tr>
              </tbody>
            </table>
            <div class="mt-3">
              <button class="btn-municipal-warning" @click="deshacerCondonacion" :disabled="loading">
                <font-awesome-icon icon="undo" />
                Deshacer Condonación
              </button>
            </div>
          </div>
          <div v-else class="text-center py-3 text-muted">
            <p>No hay condonaciones registradas</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';
import Swal from 'sweetalert2';
import { useRouter } from 'vue-router';
import { useGlobalLoading } from '@/composables/useGlobalLoading';

const { showLoading, hideLoading } = useGlobalLoading();

const router = useRouter();

// State
const loading = ref(false);
const recaudadoras = ref([]);
const mercados = ref([]);
const form = ref({
  oficina: '',
  num_mercado: '',
  categoria: '',
  seccion: '',
  local: '',
  letra_local: '',
  bloque: ''
});
const localData = ref(null);
const adeudos = ref([]);
const condonados = ref([]);
const oficio = ref('');

// Helpers
const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value || 0);
};

const showToast = (type, message) => {
  Swal.fire({
    toast: true,
    position: 'top-end',
    icon: type,
    title: message,
    showConfirmButton: false,
    timer: 3000
  });
};

const cerrar = () => {
  router.push('/mercados');
};

// Buscar Local
async function buscarLocal() {
  loading.value = true;
  localData.value = null;
  adeudos.value = [];
  condonados.value = [];

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_condonacion_buscar_local',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_oficina', Valor: form.value.oficina, tipo: 'integer' },
          { Nombre: 'p_num_mercado', Valor: form.value.num_mercado, tipo: 'integer' },
          { Nombre: 'p_categoria', Valor: form.value.categoria, tipo: 'integer' },
          { Nombre: 'p_seccion', Valor: form.value.seccion },
          { Nombre: 'p_local', Valor: form.value.local, tipo: 'integer' },
          { Nombre: 'p_letra_local', Valor: form.value.letra_local || null },
          { Nombre: 'p_bloque', Valor: form.value.bloque || null }
        ]
      }
    });

    if (response.data?.eResponse?.success) {
      const result = response.data.eResponse.data.result;
      if (result && result.length > 0) {
        localData.value = result[0];
        showToast('Local encontrado', 'success');
        listarAdeudos();
        listarCondonados();
      } else {
        showToast('Local no encontrado', 'warning');
      }
    } else {
      showToast(response.data?.eResponse?.message || 'Error al buscar', 'error');
    }
  } catch (error) {
    console.error('Error:', error);
    showToast('Error al buscar local', 'error');
  } finally {
    loading.value = false;
  }
}

// Listar Adeudos
async function listarAdeudos() {
  if (!localData.value) return;
  loading.value = true;

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_condonacion_listar_adeudos',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_id_local', Valor: localData.value.id_local, tipo: 'integer' }
        ]
      }
    });

    if (response.data?.eResponse?.success) {
      adeudos.value = (response.data.eResponse.data.result || []).map(a => ({ ...a, selected: false }));
    }
  } catch (error) {
    console.error('Error:', error);
  } finally {
    loading.value = false;
  }
}

// Condonar Seleccionados
async function condonarSeleccionados() {
  if (!oficio.value || oficio.value.trim().length < 10) {
    showToast('Ingrese un oficio válido (mín. 10 caracteres)', 'warning');
    return;
  }

  const seleccionados = adeudos.value.filter(a => a.selected);
  if (seleccionados.length === 0) {
    showToast('Seleccione al menos un adeudo', 'warning');
    return;
  }

  const result = await Swal.fire({
    title: '¿Condonar adeudos?',
    text: `Se condonarán ${seleccionados.length} adeudo(s)`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, condonar',
    cancelButtonText: 'Cancelar'
  });

  if (!result.isConfirmed) return;

  loading.value = true;
  let exitosos = 0;

  try {
    for (const a of seleccionados) {
      const response = await axios.post('/api/generic', {
        eRequest: {
          Operacion: 'sp_condonacion_condonar',
          Base: 'mercados',
          Parametros: [
            { Nombre: 'p_id_local', Valor: localData.value.id_local, tipo: 'integer' },
            { Nombre: 'p_axo', Valor: a.axo, tipo: 'integer' },
            { Nombre: 'p_periodo', Valor: a.periodo, tipo: 'integer' },
            { Nombre: 'p_importe', Valor: a.importe, tipo: 'numeric' },
            { Nombre: 'p_oficio', Valor: oficio.value }
          ]
        }
      });

      if (response.data?.eResponse?.success) {
        exitosos++;
      }
    }

    showToast(`${exitosos} adeudo(s) condonado(s)`, 'success');
    listarAdeudos();
    listarCondonados();
  } catch (error) {
    console.error('Error:', error);
    showToast('Error al condonar', 'error');
  } finally {
    loading.value = false;
  }
}

// Listar Condonados
async function listarCondonados() {
  if (!localData.value) return;
  loading.value = true;

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_condonacion_listar_condonados',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_id_local', Valor: localData.value.id_local, tipo: 'integer' }
        ]
      }
    });

    if (response.data?.eResponse?.success) {
      condonados.value = (response.data.eResponse.data.result || []).map(c => ({ ...c, selected: false }));
    }
  } catch (error) {
    console.error('Error:', error);
  } finally {
    loading.value = false;
  }
}

// Deshacer Condonación
async function deshacerCondonacion() {
  const seleccionados = condonados.value.filter(c => c.selected);
  if (seleccionados.length === 0) {
    showToast('Seleccione al menos una condonación', 'warning');
    return;
  }

  const result = await Swal.fire({
    title: '¿Deshacer condonación?',
    text: `Se deshará ${seleccionados.length} condonación(es)`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#d33',
    confirmButtonText: 'Sí, deshacer',
    cancelButtonText: 'Cancelar'
  });

  if (!result.isConfirmed) return;

  loading.value = true;
  let exitosos = 0;

  try {
    for (const c of seleccionados) {
      const response = await axios.post('/api/generic', {
        eRequest: {
          Operacion: 'sp_condonacion_deshacer',
          Base: 'mercados',
          Parametros: [
            { Nombre: 'p_id_cancelacion', Valor: c.id_cancelacion, tipo: 'integer' },
            { Nombre: 'p_id_local', Valor: c.id_local, tipo: 'integer' },
            { Nombre: 'p_axo', Valor: c.axo, tipo: 'integer' },
            { Nombre: 'p_periodo', Valor: c.periodo, tipo: 'integer' },
            { Nombre: 'p_importe', Valor: c.importe, tipo: 'numeric' }
          ]
        }
      });

      if (response.data?.eResponse?.success) {
        exitosos++;
      }
    }

    showToast(`${exitosos} condonación(es) deshecha(s)`, 'success');
    listarAdeudos();
    listarCondonados();
  } catch (error) {
    console.error('Error:', error);
    showToast('Error al deshacer', 'error');
  } finally {
    loading.value = false;
  }
}

// Cargar Recaudadoras
async function fetchRecaudadoras() {
  showLoading('Cargando Condonación', 'Preparando oficinas recaudadoras...');
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_recaudadoras',
        Base: 'padron_licencias',
        Parametros: []
      }
    });
    if (response.data?.eResponse?.success) {
      recaudadoras.value = response.data.eResponse.data.result || [];
    }
  } catch (error) {
    console.error('Error al cargar recaudadoras:', error);
  } finally {
    hideLoading();
  }
}

// Cambio de Oficina
async function onOficinaChange() {
  form.value.num_mercado = '';
  mercados.value = [];
  if (!form.value.oficina) return;

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_consulta_locales_get_mercados',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_oficina', Valor: parseInt(form.value.oficina), tipo: 'integer' }
        ]
      }
    });
    if (response.data?.eResponse?.success) {
      mercados.value = response.data.eResponse.data.result || [];
    }
  } catch (error) {
    console.error('Error al cargar mercados:', error);
  }
}

onMounted(() => {
  fetchRecaudadoras();
});
</script>
