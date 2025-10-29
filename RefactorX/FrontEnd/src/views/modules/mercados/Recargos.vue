<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-alt" /></div>
      <div class="module-view-info">
        <h1>Recargos</h1>
        <p>Mercados - Recargos</p>
      </div>
    </div>

    <div class="module-view-content">
    <h1>Catálogo de Recargos</h1>
    <div class="mb-3">
      <button class="btn-municipal-primary" @click="showCreateModal = true">Agregar Recargo</button>
    </div>
    <table class="municipal-table">
      <thead>
        <tr>
          <th>Año</th>
          <th>Mes</th>
          <th>Porcentaje</th>
          <th>Fecha Alta</th>
          <th>Usuario</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="recargo in recargos" :key="recargo.axo + '-' + recargo.periodo">
          <td>{{ recargo.axo }}</td>
          <td>{{ recargo.periodo }}</td>
          <td>{{ recargo.porcentaje }}</td>
          <td>{{ recargo.fecha_alta | formatDate }}</td>
          <td>{{ recargo.usuario }}</td>
          <td>
            <button class="btn-icon btn-municipal-warning" @click="editRecargo(recargo)">Editar</button>
            <button class="btn-icon btn-municipal-danger" @click="deleteRecargo(recargo)">Eliminar</button>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- Crear/Editar Modal -->
    <b-modal v-model="showCreateModal" title="Agregar Recargo" hide-footer>
      <form @submit.prevent="saveRecargo">
        <div class="mb-3">
          <label class="municipal-form-label">Año</label>
          <input type="number" v-model="form.axo" class="municipal-form-control" required />
        </div>
        <div class="mb-3">
          <label class="municipal-form-label">Mes</label>
          <input type="number" v-model="form.periodo" class="municipal-form-control" min="1" max="12" required />
        </div>
        <div class="mb-3">
          <label class="municipal-form-label">Porcentaje</label>
          <input type="number" v-model="form.porcentaje" class="municipal-form-control" step="0.01" required />
        </div>
        <div class="mb-3">
          <label class="municipal-form-label">Usuario</label>
          <input type="number" v-model="form.usuario_id" class="municipal-form-control" required />
        </div>
        <div class="d-flex justify-content-end">
          <button type="button" class="btn btn-municipal-secondary me-2" @click="showCreateModal = false">Cancelar</button>
          <button type="submit" class="btn-municipal-primary">Guardar</button>
        </div>
      </form>
    </b-modal>

    <!-- Editar Modal -->
    <b-modal v-model="showEditModal" title="Editar Recargo" hide-footer>
      <form @submit.prevent="saveRecargo(true)">
        <div class="mb-3">
          <label class="municipal-form-label">Año</label>
          <input type="number" v-model="form.axo" class="municipal-form-control" required disabled />
        </div>
        <div class="mb-3">
          <label class="municipal-form-label">Mes</label>
          <input type="number" v-model="form.periodo" class="municipal-form-control" min="1" max="12" required disabled />
        </div>
        <div class="mb-3">
          <label class="municipal-form-label">Porcentaje</label>
          <input type="number" v-model="form.porcentaje" class="municipal-form-control" step="0.01" required />
        </div>
        <div class="mb-3">
          <label class="municipal-form-label">Usuario</label>
          <input type="number" v-model="form.usuario_id" class="municipal-form-control" required />
        </div>
        <div class="d-flex justify-content-end">
          <button type="button" class="btn btn-municipal-secondary me-2" @click="showEditModal = false">Cancelar</button>
          <button type="submit" class="btn-municipal-primary">Guardar Cambios</button>
        </div>
      </form>
    </b-modal>
  </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script>
import axios from 'axios';
export default {
  name: 'RecargosPage',
  data() {
    return {
      recargos: [],
      showCreateModal: false,
      showEditModal: false,
      form: {
        axo: '',
        periodo: '',
        porcentaje: '',
        usuario_id: ''
      },
      editing: false
    };
  },
  filters: {
    formatDate(val) {
      if (!val) return '';
      return new Date(val).toLocaleDateString();
    }
  },
  mounted() {
    this.loadRecargos();
  },
  methods: {
    async loadRecargos() {
      const res = await axios.post('/api/execute', {
        eRequest: { action: 'recargos.list' }
      });
      this.recargos = res.data.eResponse.data || [];
    },
    async saveRecargo(edit = false) {
      const action = edit ? 'recargos.update' : 'recargos.create';
      const res = await axios.post('/api/execute', {
        eRequest: {
          action,
          params: { ...this.form }
        }
      }
          )
        });
        const resData = await res.json();
      if (resData.eResponse.status === 'ok') {
        this.showCreateModal = false;
        this.showEditModal = false;
        this.loadRecargos();
      } else {
        alert(res.data.eResponse.message || 'Error al guardar');
      }
    },
    editRecargo(recargo) {
      this.form = { ...recargo, usuario_id: recargo.usuario_id || '' };
      this.showEditModal = true;
    },
    async deleteRecargo(recargo) {
      if (!confirm('¿Está seguro de eliminar este recargo?')) return;
      const res = await axios.post('/api/execute', {
        eRequest: {
          action: 'recargos.delete',
          params: { axo: recargo.axo, periodo: recargo.periodo }
        }
      }
          )
        });
        const resData = await res.json();
      if (resData.eResponse.status === 'ok') {
        this.loadRecargos();
      } else {
        alert(res.data.eResponse.message || 'Error al eliminar');
      }
    }
  }
};
</script>

<style scoped>
.recargos-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
