<template>
  <div class="modulo-bd-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Catálogo de Categorías</li>
      </ol>
    </nav>
    <h1>Catálogo de Categorías</h1>
    <div class="actions mb-3">
      <button class="btn btn-primary" @click="showAddModal = true">Agregar Categoría</button>
    </div>
    <table class="table table-bordered">
      <thead>
        <tr>
          <th>ID</th>
          <th>Descripción</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="cat in categorias" :key="cat.categoria">
          <td>{{ cat.categoria }}</td>
          <td>{{ cat.descripcion }}</td>
          <td>
            <button class="btn btn-sm btn-warning" @click="editCategoria(cat)">Editar</button>
          </td>
        </tr>
      </tbody>
    </table>
    <!-- Modal Agregar -->
    <div v-if="showAddModal" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h3>Agregar Categoría</h3>
          <form @submit.prevent="addCategoria">
            <div class="form-group">
              <label>Descripción</label>
              <input v-model="newCategoria.descripcion" class="form-control" required />
            </div>
            <div class="modal-footer">
              <button class="btn btn-secondary" @click="showAddModal = false">Cancelar</button>
              <button class="btn btn-primary" type="submit">Guardar</button>
            </div>
          </form>
        </div>
      </div>
    </div>
    <!-- Modal Editar -->
    <div v-if="showEditModal" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h3>Editar Categoría</h3>
          <form @submit.prevent="updateCategoria">
            <div class="form-group">
              <label>Descripción</label>
              <input v-model="editCategoriaData.descripcion" class="form-control" required />
            </div>
            <div class="modal-footer">
              <button class="btn btn-secondary" @click="showEditModal = false">Cancelar</button>
              <button class="btn btn-primary" type="submit">Actualizar</button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'CategoriasPage',
  data() {
    return {
      categorias: [],
      showAddModal: false,
      showEditModal: false,
      newCategoria: {
        descripcion: ''
      },
      editCategoriaData: {
        categoria: null,
        descripcion: ''
      }
    }
  },
  mounted() {
    this.fetchCategorias();
  },
  methods: {
    async fetchCategorias() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'mercados.getCategorias',
          payload: {}
        });
        if (res.data.status === 'success') {
          this.categorias = res.data.data;
        }
      } catch (error) {
        console.error('Error fetching categorias:', error);
      }
    },
    async addCategoria() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'mercados.addCategoria',
          payload: this.newCategoria
        });
        if (res.data.status === 'success') {
          this.showAddModal = false;
          this.newCategoria.descripcion = '';
          this.fetchCategorias();
        } else {
          alert(res.data.message || 'Error al agregar');
        }
      } catch (error) {
        alert('Error al agregar categoria');
      }
    },
    editCategoria(cat) {
      this.editCategoriaData = { ...cat };
      this.showEditModal = true;
    },
    async updateCategoria() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'mercados.updateCategoria',
          payload: this.editCategoriaData
        });
        if (res.data.status === 'success') {
          this.showEditModal = false;
          this.fetchCategorias();
        } else {
          alert(res.data.message || 'Error al actualizar');
        }
      } catch (error) {
        alert('Error al actualizar categoria');
      }
    }
  }
}
</script>

<style scoped>
.modulo-bd-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: #f8f9fa;
  padding: 0.5rem 1rem;
  margin-bottom: 1rem;
}
.modal-mask {
  position: fixed;
  z-index: 9998;
  top: 0; left: 0; right: 0; bottom: 0;
  background-color: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
}
.modal-wrapper {
  width: 400px;
}
.modal-container {
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
}
</style>
