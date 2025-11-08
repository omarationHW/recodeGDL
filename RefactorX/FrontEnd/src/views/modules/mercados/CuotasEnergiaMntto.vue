<template>
  <div class="cuotas-energia-mntto">
    <h1>Mantenimiento Cuotas de Energía Eléctrica</h1>
    <form @submit.prevent="onSubmit">
      <div class="form-row">
        <label for="control">Control</label>
        <input type="text" id="control" v-model="form.id_kilowhatts" :readonly="isEdit" />
      </div>
      <div class="form-row">
        <label for="axo">Año</label>
        <input type="number" id="axo" v-model.number="form.axo" min="2002" required :readonly="isEdit" />
      </div>
      <div class="form-row">
        <label for="periodo">Periodo</label>
        <input type="number" id="periodo" v-model.number="form.periodo" min="1" max="12" required :readonly="isEdit" />
      </div>
      <div class="form-row">
        <label for="importe">Cuota</label>
        <input type="number" id="importe" v-model.number="form.importe" min="0.01" step="0.01" required />
      </div>
      <div class="form-actions">
        <button type="submit">{{ isEdit ? 'Actualizar' : 'Guardar' }}</button>
        <button type="button" @click="onCancel">Cancelar</button>
      </div>
    </form>
    <hr />
    <h2>Listado de Cuotas</h2>
    <div class="filter-row">
      <label>Año: <input type="number" v-model.number="filter.axo" min="2002" /></label>
      <label>Periodo: <input type="number" v-model.number="filter.periodo" min="1" max="12" /></label>
      <button @click="fetchCuotas">Buscar</button>
    </div>
    <table class="cuotas-table">
      <thead>
        <tr>
          <th>ID</th>
          <th>Año</th>
          <th>Periodo</th>
          <th>Cuota</th>
          <th>Fecha Alta</th>
          <th>Usuario</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="cuota in cuotas" :key="cuota.id_kilowhatts">
          <td>{{ cuota.id_kilowhatts }}</td>
          <td>{{ cuota.axo }}</td>
          <td>{{ cuota.periodo }}</td>
          <td>{{ cuota.importe }}</td>
          <td>{{ cuota.fecha_alta }}</td>
          <td>{{ cuota.usuario }}</td>
          <td>
            <button @click="editCuota(cuota)">Editar</button>
          </td>
        </tr>
        <tr v-if="cuotas.length === 0">
          <td colspan="7">No hay registros</td>
        </tr>
      </tbody>
    </table>
    <div v-if="message" class="message">{{ message }}</div>
  </div>
</template>

<script>
export default {
  name: 'CuotasEnergiaMntto',
  data() {
    return {
      form: {
        id_kilowhatts: '',
        axo: new Date().getFullYear(),
        periodo: 1,
        importe: '',
        id_usuario: 1 // Simulación, debe venir del login
      },
      isEdit: false,
      cuotas: [],
      filter: {
        axo: '',
        periodo: ''
      },
      message: ''
    };
  },
  mounted() {
    this.fetchCuotas();
  },
  methods: {
    async fetchCuotas() {
      this.message = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'listCuotas',
            data: {
              axo: this.filter.axo || null,
              periodo: this.filter.periodo || null
            }
          })
        });
        const json = await res.json();
        if (json.success) {
          this.cuotas = json.data;
        } else {
          this.message = json.message;
        }
      } catch (e) {
        this.message = 'Error al cargar cuotas';
      }
    },
    async onSubmit() {
      this.message = '';
      if (!this.form.importe || this.form.importe <= 0) {
        this.message = 'La cuota no puede ser cero o vacía';
        return;
      }
      const action = this.isEdit ? 'updateCuota' : 'insertCuota';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action,
            data: { ...this.form }
          })
        });
        const json = await res.json();
        if (json.success) {
          this.message = json.message || 'Operación exitosa';
          this.fetchCuotas();
          this.onCancel();
        } else {
          this.message = json.message;
        }
      } catch (e) {
        this.message = 'Error al guardar';
      }
    },
    editCuota(cuota) {
      this.form = {
        id_kilowhatts: cuota.id_kilowhatts,
        axo: cuota.axo,
        periodo: cuota.periodo,
        importe: cuota.importe,
        id_usuario: 1 // Simulación
      };
      this.isEdit = true;
      this.message = '';
    },
    onCancel() {
      this.form = {
        id_kilowhatts: '',
        axo: new Date().getFullYear(),
        periodo: 1,
        importe: '',
        id_usuario: 1
      };
      this.isEdit = false;
      this.message = '';
    }
  }
};
</script>

<style scoped>
.cuotas-energia-mntto {
  max-width: 700px;
  margin: 0 auto;
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 8px #0001;
}
.form-row {
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
}
.form-row label {
  width: 100px;
  font-weight: bold;
}
.form-row input {
  flex: 1;
  padding: 0.3rem;
}
.form-actions {
  margin-top: 1rem;
}
.cuotas-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1rem;
}
.cuotas-table th, .cuotas-table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
  text-align: left;
}
.cuotas-table th {
  background: #f0f0f0;
}
.filter-row {
  margin-bottom: 1rem;
  display: flex;
  gap: 1rem;
  align-items: center;
}
.message {
  margin-top: 1rem;
  color: #b00;
}
</style>
