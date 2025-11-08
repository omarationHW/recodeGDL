<template>
  <div class="gastos-page">
    <h1>Mantenimiento de Gastos</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Gastos</li>
      </ol>
    </nav>
    <div v-if="message" :class="{'alert': true, 'alert-success': success, 'alert-danger': !success}">{{ message }}</div>
    <form @submit.prevent="onSubmit">
      <div class="form-group">
        <label for="sdzmg">Salario Diario ZMG</label>
        <input v-model.number="form.sdzmg" type="number" step="0.01" min="0.01" class="form-control" id="sdzmg" required :disabled="isDelete" />
      </div>
      <div class="form-group">
        <label for="porc1_req">% de Requerimiento</label>
        <input v-model.number="form.porc1_req" type="number" step="0.01" min="0.01" class="form-control" id="porc1_req" required :disabled="isDelete" />
      </div>
      <div class="form-group">
        <label for="porc2_embargo">% de Embargo</label>
        <input v-model.number="form.porc2_embargo" type="number" step="0.01" min="0.01" class="form-control" id="porc2_embargo" required :disabled="isDelete" />
      </div>
      <div class="form-group">
        <label for="porc3_secuestro">% de Secuestro</label>
        <input v-model.number="form.porc3_secuestro" type="number" step="0.01" min="0.01" class="form-control" id="porc3_secuestro" required :disabled="isDelete" />
      </div>
      <div class="form-group mt-3">
        <button type="submit" class="btn btn-primary" v-if="mode === 'create'">Crear</button>
        <button type="submit" class="btn btn-success" v-if="mode === 'update'">Actualizar</button>
        <button type="button" class="btn btn-danger" @click="onDelete" v-if="mode === 'delete'">Eliminar</button>
        <button type="button" class="btn btn-secondary" @click="onCancel">Cancelar</button>
      </div>
    </form>
    <hr />
    <h2>Gastos Actuales</h2>
    <table class="table table-bordered">
      <thead>
        <tr>
          <th>Salario Diario ZMG</th>
          <th>% Requerimiento</th>
          <th>% Embargo</th>
          <th>% Secuestro</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="g in gastos" :key="g.sdzmg">
          <td>{{ g.sdzmg }}</td>
          <td>{{ g.porc1_req }}</td>
          <td>{{ g.porc2_embargo }}</td>
          <td>{{ g.porc3_secuestro }}</td>
          <td>
            <button class="btn btn-sm btn-info" @click="editGasto(g)">Editar</button>
            <button class="btn btn-sm btn-danger" @click="prepareDelete(g)">Eliminar</button>
          </td>
        </tr>
        <tr v-if="gastos.length === 0">
          <td colspan="5">No hay registros.</td>
        </tr>
      </tbody>
    </table>
    <button class="btn btn-primary" @click="prepareCreate">Nuevo Gasto</button>
  </div>
</template>

<script>
export default {
  name: 'GastosPage',
  data() {
    return {
      gastos: [],
      form: {
        sdzmg: '',
        porc1_req: '',
        porc2_embargo: '',
        porc3_secuestro: ''
      },
      mode: 'create', // create | update | delete
      message: '',
      success: true,
      isDelete: false
    }
  },
  created() {
    this.fetchGastos();
  },
  methods: {
    fetchGastos() {
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'gastos.list' })
      })
        .then(res => res.json())
        .then(res => {
          if (res.success) {
            this.gastos = res.data;
          } else {
            this.message = res.message;
            this.success = false;
          }
        });
    },
    onSubmit() {
      if (this.mode === 'create') {
        this.apiCall('gastos.create');
      } else if (this.mode === 'update') {
        this.apiCall('gastos.update');
      }
    },
    apiCall(action) {
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action, payload: this.form })
      })
        .then(res => res.json())
        .then(res => {
          this.message = res.message;
          this.success = res.success;
          if (res.success) {
            this.fetchGastos();
            this.resetForm();
          }
        });
    },
    onDelete() {
      if (confirm('¿Está seguro de eliminar todos los gastos?')) {
        fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'gastos.delete' })
        })
          .then(res => res.json())
          .then(res => {
            this.message = res.message;
            this.success = res.success;
            if (res.success) {
              this.fetchGastos();
              this.resetForm();
            }
          });
      }
    },
    editGasto(g) {
      this.form = { ...g };
      this.mode = 'update';
      this.isDelete = false;
      this.message = '';
    },
    prepareDelete(g) {
      this.form = { ...g };
      this.mode = 'delete';
      this.isDelete = true;
      this.message = 'Al eliminar, se borrarán todos los gastos.';
    },
    prepareCreate() {
      this.resetForm();
      this.mode = 'create';
      this.isDelete = false;
      this.message = '';
    },
    resetForm() {
      this.form = {
        sdzmg: '',
        porc1_req: '',
        porc2_embargo: '',
        porc3_secuestro: ''
      };
      this.mode = 'create';
      this.isDelete = false;
    },
    onCancel() {
      this.resetForm();
      this.message = '';
    }
  }
}
</script>

<style scoped>
.gastos-page {
  max-width: 600px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
.alert {
  margin-bottom: 1rem;
}
</style>
