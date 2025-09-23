<template>
  <div class="recargos-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Mantenimiento de Recargos</li>
      </ol>
    </nav>
    <h2>Mantenimiento de Recargos</h2>
    <div class="card mb-4">
      <div class="card-body">
        <form @submit.prevent="onVerifica">
          <div class="row mb-3">
            <div class="col-md-2">
              <label for="axo">Año</label>
              <input type="number" v-model.number="form.axo" min="1998" max="2999" class="form-control" required />
            </div>
            <div class="col-md-2">
              <label for="mes">Mes</label>
              <input type="number" v-model.number="form.mes" min="1" max="12" class="form-control" required />
            </div>
            <div class="col-md-2 align-self-end">
              <button type="submit" class="btn btn-primary">Verificar</button>
            </div>
          </div>
        </form>
        <div v-if="showForm" class="border rounded p-3 bg-light">
          <h5>{{ isAlta ? 'Alta de Recargo' : 'Modificar Recargo' }}</h5>
          <form @submit.prevent="onGuardar">
            <div class="row mb-2">
              <div class="col-md-3">
                <label>Porcentaje Parcial (%)</label>
                <input type="number" v-model.number="form.porcentaje_parcial" min="0.01" max="100" step="0.01" class="form-control" required />
              </div>
              <div class="col-md-3">
                <label>Porcentaje Acumulado (%)</label>
                <input type="number" v-model.number="form.porcentaje_global" class="form-control" disabled />
              </div>
            </div>
            <button type="submit" class="btn btn-success me-2">{{ isAlta ? 'Guardar Alta' : 'Guardar Cambios' }}</button>
            <button type="button" class="btn btn-secondary" @click="showForm=false">Cancelar</button>
          </form>
        </div>
      </div>
    </div>
    <div class="card">
      <div class="card-header">Histórico de Recargos por Mes</div>
      <div class="card-body p-0">
        <table class="table table-striped table-bordered mb-0">
          <thead>
            <tr>
              <th>Año</th>
              <th>Mes</th>
              <th>Porcentaje Parcial</th>
              <th>Porcentaje Acumulado</th>
              <th>Usuario</th>
              <th>Fecha Mov.</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in lista" :key="item.axo + '-' + item.mes">
              <td>{{ item.axo }}</td>
              <td>{{ item.mes }}</td>
              <td>{{ item.porcentaje_parcial }}</td>
              <td>{{ item.porcentaje_global }}</td>
              <td>{{ item.usuario }}</td>
              <td>{{ item.fecha_mov ? (item.fecha_mov.substr(0,10)) : '' }}</td>
            </tr>
            <tr v-if="lista.length === 0">
              <td colspan="6" class="text-center">Sin datos</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div v-if="alerta" class="alert alert-info mt-3">{{ alerta }}</div>
  </div>
</template>

<script>
export default {
  name: 'RecargosPage',
  data() {
    return {
      form: {
        axo: new Date().getFullYear(),
        mes: new Date().getMonth() + 1,
        porcentaje_parcial: 0.5,
        porcentaje_global: 0
      },
      showForm: false,
      isAlta: true,
      lista: [],
      alerta: ''
    };
  },
  mounted() {
    this.cargarLista();
  },
  methods: {
    async cargarLista() {
      // Carga lista por mes actual
      const mes = this.form.mes;
      const res = await this.api('recargos.list', { mes });
      if (res.success) {
        this.lista = res.data;
      } else {
        this.lista = [];
      }
    },
    async onVerifica() {
      this.alerta = '';
      if (!this.form.axo || !this.form.mes) {
        this.alerta = 'Debe ingresar año y mes válidos';
        return;
      }
      const res = await this.api('recargos.get', { axo: this.form.axo, mes: this.form.mes });
      if (res.success && res.data && res.data.length > 0) {
        // Existe, modificar
        this.isAlta = false;
        const item = res.data[0];
        this.form.porcentaje_parcial = item.porcentaje_parcial;
        this.form.porcentaje_global = item.porcentaje_global;
      } else {
        // Alta
        this.isAlta = true;
        this.form.porcentaje_parcial = 1;
        this.form.porcentaje_global = 0;
      }
      this.showForm = true;
    },
    async onGuardar() {
      this.alerta = '';
      if (!this.form.porcentaje_parcial || this.form.porcentaje_parcial <= 0) {
        this.alerta = 'El porcentaje parcial debe ser mayor a 0';
        return;
      }
      const usuario = this.$store?.state?.user?.id || 1;
      let res;
      if (this.isAlta) {
        res = await this.api('recargos.create', {
          axo: this.form.axo,
          mes: this.form.mes,
          porcentaje_parcial: this.form.porcentaje_parcial,
          usuario
        });
      } else {
        res = await this.api('recargos.update', {
          axo: this.form.axo,
          mes: this.form.mes,
          porcentaje_parcial: this.form.porcentaje_parcial,
          usuario
        });
      }
      if (res.success) {
        // Recalcular acumulado
        await this.api('recargos.acumulado', { axo: this.form.axo, mes: this.form.mes });
        this.alerta = this.isAlta ? 'Registro dado de alta correctamente' : 'Registro modificado correctamente';
        this.showForm = false;
        this.cargarLista();
      } else {
        this.alerta = res.message || 'Error al guardar';
      }
    },
    async api(action, params) {
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({ action, params })
        });
        return await res.json();
      } catch (e) {
        return { success: false, message: e.message };
      }
    }
  }
};
</script>

<style scoped>
.recargos-page {
  max-width: 900px;
  margin: 0 auto;
}
.card {
  margin-bottom: 1.5rem;
}
</style>
