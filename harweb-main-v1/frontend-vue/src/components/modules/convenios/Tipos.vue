<template>
  <div class="tipos-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Tipos de Convenios</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">Tipos de Convenios</h5>
        <button class="btn btn-primary" @click="openAddModal">Agregar Tipo</button>
      </div>
      <div class="card-body">
        <table class="table table-striped">
          <thead>
            <tr>
              <th>Tipo</th>
              <th>Descripción</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="tipo in tipos" :key="tipo.tipo">
              <td>{{ tipo.tipo }}</td>
              <td>{{ tipo.descripcion }}</td>
              <td>
                <button class="btn btn-sm btn-warning" @click="openEditModal(tipo)">Editar</button>
                <button class="btn btn-sm btn-danger" @click="deleteTipo(tipo.tipo)">Eliminar</button>
              </td>
            </tr>
            <tr v-if="tipos.length === 0">
              <td colspan="3" class="text-center">No hay tipos registrados.</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Modal -->
    <div v-if="showModal" class="modal-backdrop">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ isEdit ? 'Editar Tipo' : 'Agregar Tipo' }}</h5>
            <button type="button" class="close" @click="closeModal">&times;</button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="saveTipo">
              <div class="form-group">
                <label for="tipo">Tipo</label>
                <input type="number" v-model.number="form.tipo" :readonly="isEdit" class="form-control" required />
              </div>
              <div class="form-group">
                <label for="descripcion">Descripción</label>
                <input type="text" v-model="form.descripcion" class="form-control" maxlength="50" required />
              </div>
              <div class="text-right">
                <button type="button" class="btn btn-secondary mr-2" @click="closeModal">Cancelar</button>
                <button type="submit" class="btn btn-primary">Guardar</button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
    <!-- End Modal -->
  </div>
</template>

<script>
export default {
  name: 'TiposPage',
  data() {
    return {
      tipos: [],
      showModal: false,
      isEdit: false,
      form: {
        tipo: '',
        descripcion: ''
      },
      loading: false
    };
  },
  mounted() {
    this.fetchTipos();
  },
  methods: {
    async fetchTipos() {
      this.loading = true;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'get_tipos' })
        });
        const data = await res.json();
        if (data.success) {
          this.tipos = data.data;
        } else {
          this.$toast && this.$toast.error(data.message || 'Error al cargar tipos');
        }
      } catch (e) {
        this.$toast && this.$toast.error('Error de red');
      } finally {
        this.loading = false;
      }
    },
    openAddModal() {
      this.isEdit = false;
      this.form = { tipo: '', descripcion: '' };
      this.showModal = true;
    },
    openEditModal(tipo) {
      this.isEdit = true;
      this.form = { tipo: tipo.tipo, descripcion: tipo.descripcion };
      this.showModal = true;
    },
    closeModal() {
      this.showModal = false;
    },
    async saveTipo() {
      const action = this.isEdit ? 'update_tipo' : 'add_tipo';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action, payload: this.form })
        });
        const data = await res.json();
        if (data.success) {
          this.$toast && this.$toast.success(data.message);
          this.closeModal();
          this.fetchTipos();
        } else {
          this.$toast && this.$toast.error(data.message || 'Error al guardar');
        }
      } catch (e) {
        this.$toast && this.$toast.error('Error de red');
      }
    },
    async deleteTipo(tipo) {
      if (!confirm('¿Está seguro de eliminar este tipo?')) return;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'delete_tipo', payload: { tipo } })
        });
        const data = await res.json();
        if (data.success) {
          this.$toast && this.$toast.success(data.message);
          this.fetchTipos();
        } else {
          this.$toast && this.$toast.error(data.message || 'Error al eliminar');
        }
      } catch (e) {
        this.$toast && this.$toast.error('Error de red');
      }
    }
  }
};
</script>

<style scoped>
.tipos-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 0;
}
.modal-backdrop {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.4);
  z-index: 1050;
  display: flex;
  align-items: center;
  justify-content: center;
}
.modal-dialog {
  background: #fff;
  border-radius: 6px;
  max-width: 400px;
  width: 100%;
  box-shadow: 0 2px 16px rgba(0,0,0,0.2);
}
.modal-header {
  border-bottom: 1px solid #eee;
  padding: 1rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.modal-body {
  padding: 1rem;
}
.close {
  background: none;
  border: none;
  font-size: 1.5rem;
  line-height: 1;
}
</style>
