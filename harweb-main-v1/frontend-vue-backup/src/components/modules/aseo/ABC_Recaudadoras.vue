<template>
  <div class="abc-recaudadoras-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Catálogo de Recaudadoras</li>
      </ol>
    </nav>
    <h1>Catálogo de Recaudadoras</h1>
    <div class="mb-3">
      <button class="btn btn-success" @click="showInsert = true">Agregar Recaudadora</button>
    </div>
    <table class="table table-striped">
      <thead>
        <tr>
          <th>No. Recaudadora</th>
          <th>Descripción</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="rec in recaudadoras" :key="rec.num_rec">
          <td>{{ rec.num_rec }}</td>
          <td>{{ rec.descripcion }}</td>
          <td>
            <button class="btn btn-primary btn-sm" @click="editRec(rec)">Editar</button>
            <button class="btn btn-danger btn-sm" @click="deleteRec(rec.num_rec)">Eliminar</button>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- Insert Modal -->
    <div v-if="showInsert" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h3>Agregar Recaudadora</h3>
          <form @submit.prevent="insertRec">
            <div class="form-group">
              <label>No. Recaudadora</label>
              <input type="number" v-model="form.num_rec" class="form-control" required min="1" />
            </div>
            <div class="form-group">
              <label>Descripción</label>
              <input type="text" v-model="form.descripcion" class="form-control" required maxlength="80" />
            </div>
            <div class="modal-footer">
              <button class="btn btn-secondary" @click="showInsert = false">Cancelar</button>
              <button class="btn btn-success" type="submit">Guardar</button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Edit Modal -->
    <div v-if="showEdit" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h3>Editar Recaudadora</h3>
          <form @submit.prevent="updateRec">
            <div class="form-group">
              <label>No. Recaudadora</label>
              <input type="number" v-model="form.num_rec" class="form-control" required min="1" disabled />
            </div>
            <div class="form-group">
              <label>Descripción</label>
              <input type="text" v-model="form.descripcion" class="form-control" required maxlength="80" />
            </div>
            <div class="modal-footer">
              <button class="btn btn-secondary" @click="showEdit = false">Cancelar</button>
              <button class="btn btn-primary" type="submit">Actualizar</button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <div v-if="message" class="alert alert-info mt-3">{{ message }}</div>
  </div>
</template>

<script>
export default {
  name: 'ABCRecaudadorasPage',
  data() {
    return {
      recaudadoras: [],
      showInsert: false,
      showEdit: false,
      form: {
        num_rec: '',
        descripcion: ''
      },
      message: ''
    };
  },
  mounted() {
    this.fetchRecaudadoras();
  },
  methods: {
    async fetchRecaudadoras() {
      this.message = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'getRecaudadoras'
        });
        if (res.data.status === 'success') {
          this.recaudadoras = res.data.data;
        } else {
          this.message = res.data.message;
        }
      } catch (error) {
        this.message = 'Error de conexión: ' + error.message;
      }
    },
    async insertRec() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'insertRecaudadora',
          payload: {
            num_rec: this.form.num_rec,
            descripcion: this.form.descripcion
          }
        });
        this.message = res.data.message;
        if (res.data.status === 'success') {
          this.showInsert = false;
          this.form = { num_rec: '', descripcion: '' };
          this.fetchRecaudadoras();
        }
      } catch (error) {
        this.message = 'Error de conexión: ' + error.message;
      }
    },
    editRec(rec) {
      this.form = { ...rec };
      this.showEdit = true;
    },
    async updateRec() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'updateRecaudadora',
          payload: {
            num_rec: this.form.num_rec,
            descripcion: this.form.descripcion
          }
        });
        this.message = res.data.message;
        if (res.data.status === 'success') {
          this.showEdit = false;
          this.form = { num_rec: '', descripcion: '' };
          this.fetchRecaudadoras();
        }
      } catch (error) {
        this.message = 'Error de conexión: ' + error.message;
      }
    },
    async deleteRec(num_rec) {
      if (!confirm('¿Está seguro de eliminar la recaudadora?')) return;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'deleteRecaudadora',
          payload: { num_rec }
        });
        this.message = res.data.message;
        if (res.data.status === 'success') {
          this.fetchRecaudadoras();
        }
      } catch (error) {
        this.message = 'Error de conexión: ' + error.message;
      }
    }
  }
};
</script>

<style scoped>
.abc-recaudadoras-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
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
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.33);
  padding: 2rem;
}
.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  margin-top: 1rem;
}
</style>
