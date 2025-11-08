<template>
  <div class="recargos-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Recargos</li>
      </ol>
    </nav>
    <h1>Catálogo de Recargos</h1>
    <div class="mb-3">
      <button class="btn btn-primary" @click="showCreateModal = true">Agregar Recargo</button>
    </div>
    <table class="table table-striped">
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
            <button class="btn btn-sm btn-warning" @click="editRecargo(recargo)">Editar</button>
            <button class="btn btn-sm btn-danger" @click="deleteRecargo(recargo)">Eliminar</button>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- Crear/Editar Modal -->
    <b-modal v-model="showCreateModal" title="Agregar Recargo" hide-footer>
      <form @submit.prevent="saveRecargo">
        <div class="mb-3">
          <label>Año</label>
          <input type="number" v-model="form.axo" class="form-control" required />
        </div>
        <div class="mb-3">
          <label>Mes</label>
          <input type="number" v-model="form.periodo" class="form-control" min="1" max="12" required />
        </div>
        <div class="mb-3">
          <label>Porcentaje</label>
          <input type="number" v-model="form.porcentaje" class="form-control" step="0.01" required />
        </div>
        <div class="mb-3">
          <label>Usuario</label>
          <input type="number" v-model="form.usuario_id" class="form-control" required />
        </div>
        <div class="d-flex justify-content-end">
          <button type="button" class="btn btn-secondary me-2" @click="showCreateModal = false">Cancelar</button>
          <button type="submit" class="btn btn-primary">Guardar</button>
        </div>
      </form>
    </b-modal>

    <!-- Editar Modal -->
    <b-modal v-model="showEditModal" title="Editar Recargo" hide-footer>
      <form @submit.prevent="saveRecargo(true)">
        <div class="mb-3">
          <label>Año</label>
          <input type="number" v-model="form.axo" class="form-control" required disabled />
        </div>
        <div class="mb-3">
          <label>Mes</label>
          <input type="number" v-model="form.periodo" class="form-control" min="1" max="12" required disabled />
        </div>
        <div class="mb-3">
          <label>Porcentaje</label>
          <input type="number" v-model="form.porcentaje" class="form-control" step="0.01" required />
        </div>
        <div class="mb-3">
          <label>Usuario</label>
          <input type="number" v-model="form.usuario_id" class="form-control" required />
        </div>
        <div class="d-flex justify-content-end">
          <button type="button" class="btn btn-secondary me-2" @click="showEditModal = false">Cancelar</button>
          <button type="submit" class="btn btn-primary">Guardar Cambios</button>
        </div>
      </form>
    </b-modal>
  </div>
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
      });
      if (res.data.eResponse.success) {
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
      });
      if (res.data.eResponse.success) {
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
