defmodule FleetApi.Direct.Test do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Httpc, options: [clear_mock: true]

  import FleetApi.Direct

  setup_all do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes", "fixture/custom_cassettes")
    :ok
  end

  test "list_units" do
    use_cassette "list_units", custom: true do
      {:ok, pid} = FleetApi.Direct.start_link("http://localhost:7002")
      {:ok, units} = list_units(pid)

      assert 4 == length(units)

      assert %FleetApi.Unit{
        currentState: "launched",
        desiredState: "launched",
        machineID: "820c30c0867844129d63f4409871ba39",
        name: "subgun-http.service",
        options: [
          %FleetApi.UnitOption{
            name: "Description",
            section: "Unit",
            value: "subgun"},
          %FleetApi.UnitOption{
            name: "ExecStartPre",
            section: "Service",
            value: "-/usr/bin/docker kill subgun-%i"},
          %FleetApi.UnitOption{
            name: "ExecStartPre",
            section: "Service",
            value: "-/usr/bin/docker rm subgun-%i"},
          %FleetApi.UnitOption{
            name: "ExecStart",
            section: "Service",
            value: "/usr/bin/docker run --rm --name subgun-%i -e SUBGUN_LISTEN=127.0.0.1:8080 -e SUBGUN_LISTS=recv@sandbox2398.mailgun.org -e SUBGUN_API_KEY=key-779ru4cibbnhfa1qp7a3apyvwkls7ny7 -p 8080:8080 coreos/subgun"},
          %FleetApi.UnitOption{
            name: "ExecStop",
            section: "Service",
            value: "/usr/bin/docker stop subgun-%i"},
          %FleetApi.UnitOption{
            name: "Conflicts",
            section: "X-Fleet",
            value: "subgun-http@*.service"}]} in units

      assert %FleetApi.Unit{
        currentState: "inactive",
        desiredState: "launched",
        machineID: "76ffb3a4588c46f3941c073df77be5e9",
        name: "subgun-http@.service",
        options: [
          %FleetApi.UnitOption{
            name: "Description",
            section: "Unit",
            value: "subgun"},
          %FleetApi.UnitOption{
            name: "ExecStartPre",
            section: "Service",
            value: "-/usr/bin/docker kill subgun-%i"},
          %FleetApi.UnitOption{
            name: "ExecStartPre",
            section: "Service",
            value: "-/usr/bin/docker rm subgun-%i"},
          %FleetApi.UnitOption{
            name: "ExecStart",
            section: "Service",
            value: "/usr/bin/docker run --rm --name subgun-%i -e SUBGUN_LISTEN=127.0.0.1:8080 -e SUBGUN_LISTS=recv@sandbox2398.mailgun.org -e SUBGUN_API_KEY=key-779ru4cibbnhfa1qp7a3apyvwkls7ny7 -p 8080:8080 coreos/subgun"},
          %FleetApi.UnitOption{
            name: "ExecStop",
            section: "Service",
            value: "/usr/bin/docker stop subgun-%i"},
          %FleetApi.UnitOption{
            name: "Conflicts",
            section: "X-Fleet",
            value: "subgun-http@*.service"}]} in units
    end
  end

  test "list_units empty list" do
    use_cassette "list_units_empty", custom: true do
      {:ok, pid} = FleetApi.Direct.start_link("http://localhost:7002")
      {:ok, units} = list_units(pid)

      assert 0 == length(units)
    end
  end

  test "list_units nil list instead of empty list" do
    use_cassette "list_units_null", custom: true do
      {:ok, pid} = FleetApi.Direct.start_link("http://localhost:7002")
      {:ok, units} = list_units(pid)

      assert 0 == length(units)
    end
  end

  test "list_units no units field in response" do
    use_cassette "list_units_weird_response", custom: true do
      {:ok, pid} = FleetApi.Direct.start_link("http://localhost:7002")
      {:ok, units} = list_units(pid)

      assert 0 == length(units)
    end
  end

  test "get_unit" do
    use_cassette "get_unit", custom: true do
      {:ok, pid} = FleetApi.Direct.start_link("http://localhost:7002")
      {:ok, unit} = get_unit(pid, "subgun-http.service")
      
      assert "subgun-http.service" == unit.name
      assert "launched" == unit.currentState
      assert "launched" == unit.desiredState
      assert %FleetApi.UnitOption{name: "Description", section: "Unit", value: "subgun"} in unit.options
    end
  end

  test "get_unit empty options list" do
    use_cassette "get_unit_empty_options", custom: true do
      {:ok, pid} = FleetApi.Direct.start_link("http://localhost:7002")
      {:ok, unit} = get_unit(pid, "subgun-http.service")

      assert "subgun-http.service" == unit.name
      assert "launched" == unit.currentState
      assert "launched" == unit.desiredState
      assert length(unit.options) == 0
    end
  end

  test "get_unit null options list" do
    use_cassette "get_unit_null_options", custom: true do
      {:ok, pid} = FleetApi.Direct.start_link("http://localhost:7002")
      {:ok, unit} = get_unit(pid, "subgun-http.service")

      assert "subgun-http.service" == unit.name
      assert "launched" == unit.currentState
      assert "launched" == unit.desiredState
      assert length(unit.options) == 0
    end
  end

  test "get_unit missing options list" do
    use_cassette "get_unit_missing_options", custom: true do
      {:ok, pid} = FleetApi.Direct.start_link("http://localhost:7002")
      {:ok, unit} = get_unit(pid, "subgun-http.service")

      assert "subgun-http.service" == unit.name
      assert "launched" == unit.currentState
      assert "launched" == unit.desiredState
      assert length(unit.options) == 0
    end
  end

  test "delete_unit" do
    use_cassette "delete_unit", custom: true do
      {:ok, pid} = FleetApi.Direct.start_link("http://localhost:7002")
      assert :ok = delete_unit(pid, "subgun-http.service")
    end
  end

  test "list_machines" do
    use_cassette "list_machines", custom: true do
      {:ok, pid} = FleetApi.Direct.start_link("http://localhost:7002")
      {:ok, machines} = list_machines(pid)

      assert length(machines) == 3

      assert %FleetApi.Machine{
        id: "76ffb3a4588c46f3941c073df77be5e9",
        metadata: nil,
        primaryIP: "127.0.0.1"} in machines

      assert %FleetApi.Machine{
        id: "820c30c0867844129d63f4409871ba39",
        metadata: nil,
        primaryIP: "127.0.0.2"} in machines

      assert %FleetApi.Machine{
        id: "f439a6a2dd8f43dbad60994cc1fb68f6",
        metadata: nil,
        primaryIP: "127.0.0.3"} in machines
    end
  end

  test "list_machines empty machine list" do
    use_cassette "list_machines_empty", custom: true do
      {:ok, pid} = FleetApi.Direct.start_link("http://localhost:7002")
      {:ok, machines} = list_machines(pid)

      assert length(machines) == 0
    end
  end

  test "list_machines null machine list" do
    use_cassette "list_machines_null", custom: true do
      {:ok, pid} = FleetApi.Direct.start_link("http://localhost:7002")
      {:ok, machines} = list_machines(pid)

      assert length(machines) == 0
    end
  end

  test "list_machines no machines field in response" do
    use_cassette "list_machines_weird_response", custom: true do
      {:ok, pid} = FleetApi.Direct.start_link("http://localhost:7002")
      {:ok, machines} = list_machines(pid)

      assert length(machines) == 0
    end
  end

  test "list_unit_states" do
    use_cassette "list_unit_states", custom: true do
      {:ok, pid} = FleetApi.Direct.start_link("http://localhost:7002")
      {:ok, states} = list_unit_states(pid)

      assert length(states) == 1

      assert %FleetApi.UnitState{
        hash: "eef29cad431ad16c8e164400b2f3c85afd73b238",
        machineID: "820c30c0867844129d63f4409871ba39",
        name: "subgun-http.service",
        systemdActiveState: "active",
        systemdLoadState: "loaded",
        systemdSubState: "running"} in states
    end
  end

  test "list_unit_states empty states list" do
    use_cassette "list_unit_states_empty", custom: true do
      {:ok, pid} = FleetApi.Direct.start_link("http://localhost:7002")
      {:ok, states} = list_unit_states(pid)

      assert length(states) == 0
    end
  end

  test "list_unit_states null states list" do
    use_cassette "list_unit_states_null", custom: true do
      {:ok, pid} = FleetApi.Direct.start_link("http://localhost:7002")
      {:ok, states} = list_unit_states(pid)

      assert length(states) == 0
    end
  end

  test "list_unit_states missing states list" do
    use_cassette "list_unit_states_weird_response", custom: true do
      {:ok, pid} = FleetApi.Direct.start_link("http://localhost:7002")
      {:ok, states} = list_unit_states(pid)

      assert length(states) == 0
    end
  end

  test "create unit" do
    use_cassette "set_unit_new", custom: true do
      unit = %FleetApi.Unit{
        name: "test.service",
        desiredState: "launched",
        options: [
          %FleetApi.UnitOption{
            name: "ExecStart",
            section: "Service",
            value: "/usr/bin/sleep 3000"
          }
        ]

      }

      {:ok, pid} = FleetApi.Direct.start_link("http://localhost:7002")
      assert :ok = set_unit(pid, "test.service", unit)
    end
  end

  test "update_unit_desired_state" do
    use_cassette "set_unit_update", custom: true do
      {:ok, pid} = FleetApi.Direct.start_link("http://localhost:7002")
      assert :ok = set_unit(pid, "test.service", "launched")
    end
  end

  test "get_api_discovery" do
    use_cassette "get_api_discovery", custom: true do
      {:ok, pid} = FleetApi.Direct.start_link("http://localhost:7002")
      {:ok, discovery} = get_api_discovery(pid)

      assert discovery["discoveryVersion"] == "v1"
      assert discovery["id"] == "fleet:v1"
      assert discovery["title"] == "fleet API"
    end
  end
end